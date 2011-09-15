Preview =
  scrapers: [ ]
  
  register: (scraper) ->
    @scrapers.push scraper
  
  loadPreviews: (message, link) ->
    uri = new Uri link.href
    
    for scraper in @scrapers
      if scraper.doesUriMatch uri
        break if new scraper(message, link, uri).scrape()

notImplemented = (constructor, method) ->
  constructor::[method] = -> throw new Error "Method #{method} must be implemented by #{constructor}"

class Preview.BasicScraper
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

class Preview.SummaryScraper extends Preview.BasicScraper
  
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

class Preview.ThumbnailScraper extends Preview.BasicScraper
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

window.Preview = Preview;