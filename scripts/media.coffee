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
                      .addClass('media-item')
                      .append(@thumbnailLink.append @thumbnailImage)
    @preview.appendTo $('.media', @message)

class YouTubeScraper extends Media.ThumbnailScraper
  Media.register this
  
  @doesUriMatch: (uri) ->
    if uri.matchHost 'youtube.com'
      uri.query.v? or
      uri.matchPath '/v/'
    else
      uri.host is 'youtu.be'
  
  loadPreview: ->
    if @uri.host is 'youtu.be'
      id = uri.path.substring 1
    else
      id = @uri.query.v ? @uri.path.match(/^\/v\/(.+)$/)?[1]
    
    if id?
      $.get "https://gdata.youtube.com/feeds/api/videos/#{id}?v=2", (xml) =>
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

class ImgurScraper extends Media.ThumbnailScraper
  Media.register this
  
  @doesUriMatch: (uri) ->
    if uri.host is 'imgur.com' or uri.host is 'i.imgur.com'
      true
    else
      false
  
  loadPreview: ->
    id = @uri.path.match(/// ([^/]+) (?: \. [^/]+ )? $ ///)?[1]
    
    if id?
      $.getJSON "http://api.imgur.com/2/image/#{id}", (data) =>
        @setPreviewTitle data.image.image.title ? @source.text()
        @setPreviewImage data.image.links.small_square
        @setPreviewLink data.image.links.imgur_page

class GenericImageScraper extends Media.ThumbnailScraper
  Media.register this
  
  PATTERN = /// \. (?: bmp | gif | jp2 | jpe?g | png | tiff? ) $///i
  
  @doesUriMatch: (uri) ->
    uri.path.match(PATTERN)?
  
  loadPreview: ->
    @setPreviewImage 'images/camera.png'

window.Media = Media;