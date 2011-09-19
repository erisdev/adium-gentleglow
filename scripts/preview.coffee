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
  PREVIEW_TEMPLATE = '''
    <article>
      <div class="thumbnail">
        <a><img alt></a>
      </div>
      <div class="snippet">
        <h1 class="title">
          <a>lorem ipsum</a>
        </h1>
        <p class="content"></p>
      </div>
    </article>
  '''
  
  setPreviewLink: (uri) ->
    $('.thumbnail a, .title a', @preview).attr href: uri
  
  setPreviewTitle: (title) ->
    $('.title a', @preview).text title
  
  setPreviewText: (text, rich = false) ->
    if rich
      $('.content', @preview).html text
    else
      $('.content', @preview).text text
  
  createDefaultPreview: ->
    @preview = $(PREVIEW_TEMPLATE).appendTo $('.previews', @message)
    
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