class VimeoScraper extends Preview.ThumbnailScraper
  Preview.register this
  
  @doesUriMatch: (uri) ->
    uri.isInDomain('vimeo.com') and
    uri.path.search(/^\/\d+$/) >= 0
  
  scrape: ->
    if id = @uri.path.match(/^\/(\d+)$/)?[1]
      $.ajax "http://vimeo.com/api/v2/video/#{id}.json",
        type: 'get', dataType: 'json', error: @pass
        success: ([video]) =>
          @createPreview
            title: video.title
            thumbnail: video.thumbnail_small
    else
      @pass()
