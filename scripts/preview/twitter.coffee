{BasicScraper} = require 'preview'

exports = class TwitterScraper extends BasicScraper
  TWEET_PATTERN = /// /status/ (\d+) $///
  
  @doesUriMatch: (uri) ->
    uri.isInDomain('twitter.com') and
    (uri.fragment ? uri.path)?.match(TWEET_PATTERN)?
  
  scrape: ->
    if id = (@uri.fragment ? @uri.path)?.match(TWEET_PATTERN)?[1]
      this.ajax "http://api.twitter.com/1/statuses/show/#{id}.json", include_entities: true, (tweet) =>
        user = tweet.user
        this.createPreview
          title: "@#{user.screen_name}: #{tweet.text})"
          thumbnail: user.profile_image_url
          snippet: @parseEntities(tweet)
          timestamp: new Date(tweet.created_at)
          author: { name: user.name, uri: "http://twitter.com/#{user.screen_name}" }
        
        # TODO add more information
    else
      @pass()
  
  parseEntities: (tweet) ->
    # This function converts a tweet with "entity" metadata 
    # from plain text to linkified HTML.
    #
    # See the documentation here: http://dev.twitter.com/pages/tweet_entities
    # Basically, add ?include_entities=true to your timeline call
    #
    # Copyright 2010, Wade Simmons
    # Licensed under the MIT license
    # http://wades.im/mons
    if tweet.entities?
      indexMap = { }
      for item in tweet.entities.urls
        indexMap[item.indices[0]] = [item.indices[1], (text) -> "<a href='#{item.url.escapeEntities()}'>#{text.escapeEntities()}</a>" ]
      for item in tweet.entities.hashtags
        indexMap[item.indices[0]] = [item.indices[1], (text) -> "<a href='http://twitter.com/search?q=#{item.text.escapeEntities()}'>#{text.escapeEntities()}</a>" ]
      for item in tweet.entities.user_mentions
        indexMap[item.indices[0]] = [item.indices[1], (text) -> "<a href='http://twitter.com/#{item.screen_name}' title='#{item.name.escapeEntities()}'>#{text.escapeEntities()}</a>" ]
      
      html = ''
      lastIndex = 0
      
      for index in [0...tweet.text.length]
        if entry = indexMap[index]
          [end, fn] = entry
          if index > lastIndex
            html += tweet.text.substring(lastIndex, index).escapeEntities()
          html += fn tweet.text.substring(index, end)
          index = end - 1
          lastIndex = end
      
      if index > lastIndex
        html += tweet.text.substring(lastIndex, index).escapeEntities()
      
      html
    else
      tweet.text.escapeEntities()
