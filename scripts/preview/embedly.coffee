class EmbedlyScraper extends Preview.BasicScraper
  Preview.register this
  
  # This scraper is optimistic because its scope is so broad. Now that
  # scrapers are chainable, saying yes here doesn't necessarily prevent
  # others running too.
  @doesUriMatch: (uri) -> MessageStyle.environment.EMBEDLY_KEY?
  
  scrape: ->
    $.ajax 'http://api.embed.ly/1/oembed'
      type: 'get', dataType: 'json'
      error: @pass
      success: @embed
      data:
        url: "#{@uri}"
        key: MessageStyle.environment.EMBEDLY_KEY
        words: 37
  
  embed: (oembed) =>
    preview = @createPreview
      title: oembed.title
      thumbnail: oembed.thumbnail_url
      snippet: oembed.description
      embed: oembed.html
