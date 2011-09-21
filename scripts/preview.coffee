Preview =
  scrapers: [ ]
  
  register: (scraper) ->
    @scrapers.push scraper
  
  loadPreviews: (message, link) ->
    scraperQueue = [ ]
    
    uri = new Uri link.href
    
    link = $(link)
    title = link.attr('title') ? link.text()
    
    for Scraper in @scrapers
      if Scraper.doesUriMatch uri
        scraperQueue.push new Scraper(scraperQueue, message, uri, title)
    
    if scraperQueue.length > 0
      scraperQueue.shift().scrapeOrPass()

notImplemented = (constructor, method) ->
  constructor::[method] = -> throw new Error "Method #{method} must be implemented by #{constructor}"

class Preview.BasicScraper
  @doesUriMatch: (uri) -> false
  
  constructor: (@queue, message, @uri, @title) ->
    @message = $(message)
    @isCancelled = false
  
  scrapeOrPass: ->
    try
      @scrape()
    catch ex
      # pass to the next scraper in line on error
      @pass() unless @isCancelled
    return
  
  pass: =>
    if @queue?.length > 0
      @queue.shift().scrapeOrPass()
    return
  
  cancel: =>
    @isCancelled = true
    return
  
  notImplemented this, 'createPreview'
  notImplemented this, 'scrape'

class Preview.SummaryScraper extends Preview.BasicScraper
  DEFAULT_THUMBNAIL = 'images/camera.png'
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
  
  createPreview: ({uri, title, thumbnail, snippet} = { }) ->
    preview = $(PREVIEW_TEMPLATE)
    
    uri ?= "#{@uri}"
    title ?= @title
    thumbnail ?= DEFAULT_THUMBNAIL
    snippet ?= ''
    
    $('.thumbnail a, .title a', preview).attr title: "#{title}", href: uri
    $('.thumbnail img',         preview).attr title: "#{title}", src: thumbnail
    
    if typeof title is 'string'
      $('.title a', preview).text title
    else
      $('.title a', preview).empty().append title
    
    if typeof snippet is 'string'
      $('.content', preview).text snippet
    else
      $('.content', preview).empty().append snippet
    
    preview.appendTo $('.previews', @message)

class Preview.ThumbnailScraper extends Preview.BasicScraper
  THROBBER_URI  = 'images/throbber.gif'
  
  PREVIEW_TEMPLATE = '''
    <div class="thumbnail-item">
      <a><img alt></a>
    </div>
  '''
  
  createPreview: ({uri, title, thumbnail} = { }) ->
    preview = $(PREVIEW_TEMPLATE)
    
    uri ?= "#{@uri}"
    title ?= "#{@title}"
    thumbnail ?= THROBBER_URI
    
    $('a',   preview).attr title: title, href: uri
    $('img', preview).attr title: title, src: thumbnail
    
    preview.appendTo $('.thumbnails', @message)

window.Preview = Preview;