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

class Preview.BasicScraper
  THROBBER_URI  = 'images/throbber.gif'
  DEFAULT_THUMBNAIL = 'images/camera.png'
  PREVIEW_TEMPLATE = '''
    <article>
      <div class="gg-previewThumbnail">
        <a><img alt></a>
      </div>
      <div class="gg-previewSnippet">
        <h1 class="gg-previewTitle">
          <a>lorem ipsum</a>
        </h1>
        <div class="gg-previewContent"></div>
      </div>
    </article>
  '''
  
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
  
  createPreview: ({uri, title, thumbnail, snippet} = { }) ->
    preview = $(PREVIEW_TEMPLATE)
    
    uri ?= "#{@uri}"
    title ?= @title
    thumbnail ?= DEFAULT_THUMBNAIL
    snippet ?= ''
    
    $('.gg-previewThumbnail a, .gg-previewTitle a', preview).attr title: "#{title}", href: uri
    $('.gg-previewThumbnail img',         preview).attr title: "#{title}", src: thumbnail
    
    if title instanceof jQuery
      $('.gg-previewTitle a', preview).empty().append title
    else
      $('.gg-previewTitle a', preview).text title
    
    if snippet instanceof jQuery
      $('.gg-previewContent', preview).empty().append snippet
    else
      $('.gg-previewContent', preview).empty().append $('<p>').text("#{snippet}")
    
    preview.appendTo $('.gg-previews', @message)
  
  Object.notImplemented this, 'scrape'

window.Preview = Preview

$(window).bind 'adium:message', (event) ->
  message = event.message
  unless message.hasClass 'history'
    message.find('a')
    .each( (i) -> Preview.loadPreviews message, this )
    .filter( (i) -> $(@).text() is $(@).attr('href') )
    .text( (i, text) -> text.replace /// \w+ :// ([^/]+ (?: / .{1,10} )? ) .* ///, '$1\u2026' )
    .addClass('shortened')
