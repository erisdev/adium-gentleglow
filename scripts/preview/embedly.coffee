{BasicScraper} = require 'preview'

exports = class EmbedlyScraper extends BasicScraper
  @API_KEY = require('message_style').environment.EMBEDLY_KEY
  
  # This scraper is optimistic because its scope is so broad. Now that
  # scrapers are chainable, saying yes here doesn't necessarily prevent
  # others running too.
  @doesUriMatch: (uri) -> @API_KEY?
  
  scrape: ->
    params =
      url: "#{@uri}"
      key: EmbedlyScraper.API_KEY
      words: 37
    
    this.ajax 'http://api.embed.ly/1/oembed', params, (oembed) =>
      this.createPreview
        title: oembed.title
        thumbnail: oembed.thumbnail_url
        snippet: oembed.description?.encodeEntities()
        embed: oembed.html
