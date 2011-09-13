Media =
  scrapers: [ ]
  
  register: (scraper) ->
    @scrapers.push scraper
  
  loadMedia: (message, link) ->
    container = $('.media', message)
    uri       = new Uri link.href
    
    for scraper in @scrapers
      if scraper.doesUriMatch uri
        break if new scraper(container, link, uri).scrape()

class Media.Scraper
  THROBBER_URI  = 'images/throbber.gif'
  LOADING_TITLE = 'loading\u2026'
  
  @doesUriMatch: (uri) -> false
  
  constructor: (container, link, @uri) ->
    @container = $(container)
    @source    = $(link)
  
  scrape: ->
    @container.append @createDefaultThumbnail()
    @loadThumbnail()
    true
  
  loadThumbnail: ->
    @loadThumbnailTitle()
    @loadThumbnailImage()
    @loadThumbnailLink()
  
  loadThumbnailTitle: ->
    @setThumbnailTitle @source.text()
  
  loadThumbnailImage: ->
    null
  
  loadThumbnailLink: ->
    @setThumbnailLink @source[0].href
  
  setThumbnailTitle: (title) ->
    @thumbnailLink.attr title: title
    @thumbnailImage.attr alt: title
  
  setThumbnailImage: (uri) ->
    @thumbnailImage.attr src: uri
  
  setThumbnailLink: (uri) ->
    @thumbnailLink.attr href: uri
  
  createDefaultThumbnail: ->
    @thumbnailImage = $('<img>')
                      .attr(src: THROBBER_URI, alt: LOADING_TITLE)
    @thumbnailLink  = $('<a>')
                      .attr(href: @uri, title: LOADING_TITLE)
    @thumbnail      = $('<div>')
                      .addClass('media-item')
                      .append(@thumbnailLink.append @thumbnailImage)

class YouTubeScraper extends Media.Scraper
  Media.register this
  
  @doesUriMatch: (uri) ->
    if uri.matchHost 'youtube.com'
      uri.query.v? or
      uri.matchPath '/v/'
    else
      uri.host is 'youtu.be'
  
  loadThumbnail: ->
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
        
        @setThumbnailImage xpath '/atom:entry/media:group/media:thumbnail[@yt:name="default"]/@url'
        @setThumbnailTitle xpath '/atom:entry/atom:title'
        @setThumbnailLink @uri

class ImgurScraper extends Media.Scraper
  Media.register this
  
  @doesUriMatch: (uri) ->
    if uri.host is 'imgur.com' or uri.host is 'i.imgur.com'
      true
    else
      false
  
  loadThumbnail: ->
    id = @uri.path.match(/// ([^/]+) (?: \. [^/]+ )? $ ///)?[1]
    
    if id?
      $.getJSON "http://api.imgur.com/2/image/#{id}", (data) =>
        @setThumbnailTitle data.image.image.title ? @source.text()
        @setThumbnailImage data.image.links.small_square
        @setThumbnailLink data.image.links.imgur_page

class GenericImageScraper extends Media.Scraper
  Media.register this
  
  PATTERN = /// \. (?: bmp | gif | jp2 | jpe?g | png | tiff? ) $///i
  
  @doesUriMatch: (uri) ->
    uri.path.match(PATTERN)?
  
  loadThumbnailImage: ->
    @setThumbnailImage 'images/camera.png'

window.Media = Media;