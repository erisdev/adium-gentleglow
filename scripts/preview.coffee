Media =
  scrapers: [ ]
  
  register: (scraper) ->
    @scrapers.push scraper
  
  loadMedia: (message, link) ->
    uri = new Uri link.href
    
    for scraper in @scrapers
      if scraper.doesUriMatch uri
        break if new scraper(message, link, uri).scrape()

notImplemented = (constructor, method) ->
  constructor::[method] = -> throw new Error "Method #{method} must be implemented by #{constructor}"

class Media.BasicScraper
  @doesUriMatch: (uri) -> false
  
  constructor: (message, link, @uri) ->
    @message = $(message)
    @source  = $(link)
    
    @isCancelled = false
  
  scrape: ->
    try
      @createDefaultPreview()
      @loadPreview()
    catch ex
      console.log ex
      @cancel()
    
    not @isCancelled
  
  cancel: ->
    @preview.remove()
    @isCancelled = true
  
  notImplemented this, 'createDefaultPreview'
  notImplemented this, 'loadPreview'

class Media.SummaryScraper extends Media.BasicScraper
  
  setPreviewLink: (uri) ->
    $('.snippet-link', @preview).attr href: uri
  
  setPreviewTitle: (title) ->
    $('.snippet-title', @preview).text title
  
  setPreviewText: (text) ->
    $('.snippet-text', @preview).text text
  
  createDefaultPreview: ->
    @preview = $("""
      <li class="snippet-item">
        <a class="snippet-link snippet-title"></a>
        <div class="snippet-text"></div>
      </li>
    """).appendTo $('.snippets', @message)
    
    @setPreviewLink @source[0].href
    @setPreviewTitle @source.text()
    
    @preview

class Media.ThumbnailScraper extends Media.BasicScraper
  THROBBER_URI  = 'images/throbber.gif'
  
  setPreviewTitle: (title) ->
    @thumbnailLink.attr title: title
    @thumbnailImage.attr alt: title
  
  setPreviewImage: (uri) ->
    @thumbnailImage.attr src: uri
  
  setPreviewLink: (uri) ->
    @thumbnailLink.attr href: uri
  
  createDefaultPreview: ->
    @thumbnailImage = $('<img>')
                      .attr(src: THROBBER_URI, alt: @source.text())
    @thumbnailLink  = $('<a>')
                      .attr(href: @source[0].href, title: @source.text())
    @preview        = $('<div>')
                      .addClass('thumbnail-item')
                      .append(@thumbnailLink.append @thumbnailImage)
    @preview.appendTo $('.thumbnails', @message)

class YouTubeScraper extends Media.ThumbnailScraper
  Media.register this
  
  @doesUriMatch: (uri) ->
    if uri.isInDomain 'youtube.com'
      uri.query.v? or
      uri.globPath '/v/*'
    else
      uri.host is 'youtu.be'
  
  loadPreview: ->
    if @uri.host is 'youtu.be'
      id = @uri.path.substring 1
    else
      id = @uri.query.v ? @uri.path.match(///^ /v/ (.*) ///)?[1]
    
    if id?
      $.get("https://gdata.youtube.com/feeds/api/videos/#{id}?v=2", (xml) =>
        # jump through hoops for the XPath API
        resolver = (ns) ->
          if ns is 'atom'
            xml.documentElement.namespaceURI
          else
            xml.lookupNamespaceURI ns
        xpath = (query) -> xml.evaluate(query, xml, resolver, XPathResult.STRING_TYPE, null).stringValue
        
        @setPreviewImage xpath '/atom:entry/media:group/media:thumbnail[@yt:name="default"]/@url'
        @setPreviewTitle xpath '/atom:entry/atom:title'
        @setPreviewLink @uri
      )
      .error => @cancel()

class ImgurScraper extends Media.ThumbnailScraper
  Media.register this
  
  @doesUriMatch: (uri) ->
    if uri.host is 'imgur.com' or uri.host is 'i.imgur.com'
      isAlbum = uri.globPath '/a/**'
      not isAlbum or (isAlbum and uri.fragment?)
    else
      false
  
  loadPreview: ->
    if @uri.globPath('/a/**')
      id = @uri.fragment
    else
      id = @uri.path.match(/// ([^/\.]+) (?: \. [^/\.]+ )? $ ///)?[1]
    
    if id?
      $.getJSON("http://api.imgur.com/2/image/#{id}", (data) =>
        @setPreviewTitle data.image.image.title ? @source.text()
        @setPreviewImage data.image.links.small_square
        @setPreviewLink data.image.links.imgur_page
      )
      .error => @cancel()

class GenericImageScraper extends Media.ThumbnailScraper
  Media.register this
  
  PATTERN = /// \. (?: bmp | gif | jp2 | jpe?g | png | tiff? ) $///i
  IMAGE_TYPES = [
    'image/bmp', 'image/x-windows-bmp'
    'image/gif',
    'image/jpeg'
    'image/png',
    'image/tiff', 'image/x-tiff' ]
  
  @doesUriMatch: (uri) ->
    uri.path.match(PATTERN)?
  
  loadPreview: ->
    $.ajax @uri, type: 'HEAD'
      success: (_, status, response) =>
        contentType = response.getResponseHeader 'Content-Type'
        if contentType in IMAGE_TYPES
          @setPreviewImage 'images/camera.png'
          @setImageTitle @uri.path.split('/').pop()
        else
          @cancel()
      error: => @cancel()

window.Media = Media;