class OEmbedProvider
  constructor: (@name, @endpoint, options = { }) ->
    @doesUriMatch = options.scheme
    @oEmbedOptions = options.oEmbedOptions ? { }
  
  sendRequest: (uri, scraper) ->
    format = 'json'
    $.ajax @endpoint.replace('{format}', format),
      type: 'get',
      dataType: 'json',
      data: $.extend({ }, {url: "#{uri}", format}, @oEmbedOptions)
      error: scraper.pass
      success: scraper.embed
  
  # This method is overridden in the constructor anyway.
  doesUriMatch: -> false 

class OEmbedScraper extends Preview.ThumbnailScraper
  Preview.register this
  
  @SUPPORTED_TYPES = ['video', 'photo']
  @PROVIDERS = { }
  
  @registerProvider = (name, endpoint, options) ->
    @PROVIDERS[name] = new OEmbedProvider name, endpoint, options
  
  # This scraper is optimistic because its scope is so broad. Now that
  # scrapers are chainable, saying yes here doesn't necessarily prevent
  # others running too.
  @doesUriMatch: (uri) -> true
  
  scrape: ->
    foundProvider = false
    for name, provider of OEmbedScraper.PROVIDERS
      if provider.doesUriMatch(@uri)
        provider.sendRequest @uri, this
        foundProvider = true
        break
    
    @pass() unless foundProvider
  
  embed: (oembed) =>
    if oembed.type in OEmbedScraper.SUPPORTED_TYPES
      preview = @createPreview
        title: oembed.title
        thumbnail: oembed.thumbnail_url
        embed: oembed.html
    else
      @pass()

do ->
  # List of providers found at <http://www.oembed.com/#section7>.
  provider = -> OEmbedScraper.registerProvider arguments...
  
  provider 'YouTube', 'http://www.youtube.com/oembed'
    scheme: (uri) -> uri.isInDomain('youtube.com') or uri.host is 'youtu.be'
  
  provider 'Flickr', 'http://www.flickr.com/services/oembed/'
    scheme: (uri) -> uri.isInDomain('flickr.com') and uri.globPath('/photos/*')
  
  provider 'Viddler', 'http://lab.viddler.com/services/oembed/'
    scheme: (uri) -> uri.isInDomain 'viddler.com'
  
  provider 'Qik', 'http://qik.com/api/oembed.{format}'
    scheme: (uri) -> uri.isInDomain 'qik.com'
  
  provider 'Revision3', 'http://revision2.com/api/oembed/'
    scheme: (uri) -> uri.isInDomain 'revision3.com'
  
  provider 'Hulu', 'http://www.hulu.com/api/oembed.{format}'
    scheme: (uri) -> uri.isInDomain('hulu.com') and uri.globPath('/watch/*')
  
  provider 'Vimeo', 'http://www.vimeo.com/api/oembed.{format}'
    scheme: (uri) ->
      uri.isInDomain('vimeo.com') and
      uri.path.search(///^ (?: /groups/.+/videos )? / (\d+) $///i) >= 0
  
  provider 'SmugMug', 'http://api.smugmug.com/services/oembed/'
    scheme: (uri) -> uri.isInDomain 'smugmug.com'
  
  provider 'SlideShare', 'http://www.slideshare.net/api/oembed/2'
    scheme: (uri) -> uri.isInDomain('slideshare.net') and uri.globPath('/*/*')
