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
  @doesUriMatch: (uri) -> false
  
  constructor: (@queue, message, @uri, @title) ->
    @message = $(message)
    @isCancelled = false
  
  scrapeOrPass: ->
    try
      Console.debug "Preview: trying #{@constructor.name} for #{@uri}"
      @scrape()
    catch ex
      # pass to the next scraper in line on error
      Console.error "Preview: #{this} failed with error: #{ex}"
      @pass() unless @isCancelled
    return
  
  pass: =>
    Console.debug "Preview: pass #{@constructor.name} for #{@uri}"
    if @queue?.length > 0
      @queue.shift().scrapeOrPass()
    return
  
  cancel: =>
    Console.debug "Preview: cancelled preview job for #{@uri}"
    @isCancelled = true
    return
  
  ajax: (uri, options, fn) ->
    params = {}
    for own key, value of options when not /^_/.test(key)
      params[key] = value
    
    $.ajax uri,
      type: 'get'
      dataType: options._type ? 'json'
      data: params
      error: => this.pass()
      success: (response) =>
        try
          fn response
        catch ex
          Console.error ex
          this.pass()
  
  createPreview: (options = { }) ->
    template = resources.get options.template ? 'views/preview'
    
    options.uri ?= "#{@uri}"
    options.title ?= @title
    
    @message.find('.gg-previews').append template(options)
  
  Object.notImplemented this, 'scrape'

window.Preview = Preview

$(window).bind 'adium:message', (event) ->
  message = event.message.model()
  unless message.isHistory()
    message.find('a')
    .each( (i) -> Preview.loadPreviews event.message, this )
    .filter( (i) -> $(@).text() is $(@).attr('href') )
    .text( (i, text) -> text.replace /// \w+ :// ([^/]+ (?: / .{1,10} )? ) .* ///, '$1\u2026' )
    .addClass('shortened')
