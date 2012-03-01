{BasicScraper} = require 'preview'

exports = class RedditScraper extends BasicScraper
  COMMENT_PATTERN = ///^ /r/ [^/]+ /comments/ [a-z0-9]+ / [^/]+ / ([a-z0-9]+) ///
  POST_PATTERN    = ///^ /r/ [^/]+ /comments/ ([a-z0-9]+) ///i
  
  DEFAULT_THUMBNAILS =
    default: 'images/icons/camera.png'
    self: 'images/reddit/self.png'
    
  
  @doesUriMatch: (uri) ->
    uri.isInDomain('reddit.com') and
    uri.globPath('/r/*/comments/**')
  
  scrape: ->
    if id = @uri.path.match(COMMENT_PATTERN)?[1]
      this.ajax "http://reddit.com/by_id/t1_#{id}.json", {}, (response) =>
        comment = response.data.children[0].data
        # TODO show comment snippet
        @pass()
    else if id = @uri.path.match(POST_PATTERN)?[1]
      this.ajax "http://reddit.com/by_id/t3_#{id}.json", {}, (response) =>
          @createPostPreview response.data.children[0].data
    else
      @cancel()
  
  createPostPreview: (post) ->
    base = "http://#{@uri.host}"
    
    thumbnail =
    if post.thumbnail of DEFAULT_THUMBNAILS
      "#{base}/"
    if post.thumbnail.charAt(0) is '/'
      "#{base}#{post.thumbnail}"
    else
      post.thumbnail
    
    this.createPreview
      uri: base + post.permalink
      title: post.title
      thumbnail: thumbnail
      # herpderp, Reddit entity-encodes JSON strings, which is almost as bad
      # as Imgur sending boolean values as strings.
      snippet: post.selftext_html.unescapeEntities() if post.is_self
      timestamp: new Date(post.created * 1000)
      score: post.score
      source: { name: post.domain, uri: "#{base}/domain/#{post.domain}" }
      author: { name: post.author, uri: "#{base}/user/#{post.author}" }
      section: { name: post.subreddit, uri: "#{base}/r/#{post.subreddit}" }
