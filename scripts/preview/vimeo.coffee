class VimeoScraper extends Preview.ThumbnailScraper
  Preview.register this
  
  VIDEO_PATTERN = ///^ (?: /groups/.+/videos )? / (\d+) $///i
  
  @doesUriMatch: (uri) ->
    uri.isInDomain('vimeo.com') and
    uri.path.search(VIDEO_PATTERN) >= 0
  
  scrape: ->
    if id = @uri.path.match(VIDEO_PATTERN)?[1]
      $.ajax "http://vimeo.com/api/v2/video/#{id}.json",
        type: 'get', dataType: 'json', error: @pass
        success: ([video]) =>
          @createPreview
            title: video.title
            thumbnail: video.thumbnail_small
    else
      @pass()
