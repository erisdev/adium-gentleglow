Media =
  scrapers: [ ]
  
  register: (scraper) ->
    @scrapers.push scraper
  
  loadMedia: (message, link) ->
    container = $('.media', message);
    uri       = link.href; # TODO parse
    
    for scraper in @scrapers
      if new scraper(container, link, uri).scrape()
        break

class Media.Scraper
  THROBBER_URI  = 'images/throbber.gif'
  LOADING_TITLE = 'loading\u2026'
  
  constructor: (container, link, @uri) ->
    @container = $(container)
    @source    = $(link)
  
  scrape: ->
    if @doesUriMatch @uri
      @container.append @createDefaultThumbnail()
      @loadThumbnail()
      true
    else
      false
  
  doesUriMatch: (uri) -> false
  
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
  
  LONG_PATTERN  = /// youtube\.com .* \b v= ([^&\#]+) ///i
  SHORT_PATTERN = /// youtu\.be/ ([^&\#]+) ///i
  
  doesUriMatch: (uri) ->
    uri.match(LONG_PATTERN)? or uri.match(SHORT_PATTERN)?
  
  loadThumbnail: ->
    [_, id] = @uri.match(LONG_PATTERN) || @uri.match(SHORT_PATTERN)
    
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
  
  PATTERN = /// imgur\.com/ (?:gallery/)? ([a-z0-9]+) ///i
  
  doesUriMatch: (uri) ->
    uri.match(PATTERN)?
  
  loadThumbnail: ->
    [_, id] = @uri.match PATTERN
    
    $.getJSON "http://api.imgur.com/2/image/#{id}", (data) =>
      @setThumbnailTitle data.image.image.title ? @source.text()
      @setThumbnailImage data.image.links.small_square
      @setThumbnailLink data.image.links.imgur_page

class GenericImageScraper extends Media.Scraper
  Media.register this
  
  PATTERN = /// \. (?: bmp | gif | jp2 | jpe?g | png | tiff? ) (?: \? .+ | \# .+ )? $///i
  
  doesUriMatch: (uri) ->
    uri.match(PATTERN)?
  
  loadThumbnailImage: ->
    @setThumbnailImage 'images/camera.png'

window.Media = Media;