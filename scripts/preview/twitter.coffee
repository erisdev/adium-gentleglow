class TwitterScraper extends Preview.SummaryScraper
  Preview.register this
  
  TWEET_PATTERN = /// /status/ (\d+) $///
  
  @doesUriMatch: (uri) ->
    uri.isInDomain('twitter.com') and
    (uri.fragment ? uri.path)?.match(TWEET_PATTERN)?
  
  scrape: ->
    if id = (@uri.fragment ? @uri.path)?.match(TWEET_PATTERN)?[1]
      $.ajax "http://api.twitter.com/1/statuses/show/#{id}.json",
        type: 'get', dataType: 'json', error: @pass
        # XXX REMOVE THIS LINE:
        cache: true
        success: (tweet) =>
          user = tweet.user
          preview = @createPreview
            title: "@#{user.screen_name}: #{tweet.text})"
            thumbnail: tweet.user.profile_image_url
            snippet: tweet.text
          
          # TODO add more information
    else
      @pass()
