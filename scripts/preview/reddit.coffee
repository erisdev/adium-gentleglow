class RedditScraper extends Preview.BasicScraper
  Preview.register this
  
  COMMENT_PATTERN = ///^ /r/ [^/]+ /comments/ [a-z0-9]+ / [^/]+ / ([a-z0-9]+) ///
  POST_PATTERN    = ///^ /r/ [^/]+ /comments/ ([a-z0-9]+) ///i
  
  SNIPPET_TEMPLATE = '''
    <p class="gg-previewInfo">
      (<a class="gg-redditPreviewDomain">example.com</a>)
      <span class="gg-redditPreviewKarma">37 karma</span>
      submitted <time class="gg-redditPreviewTimestamp" pubdate>ages ago</time>
      by <a class="gg-redditPreviewAuthor">nobody</a>
      to <a class="gg-redditPreviewSubreddit">subreddit</a>
    </p>
  '''
  
  @doesUriMatch: (uri) ->
    uri.isInDomain('reddit.com') and
    uri.globPath('/r/*/comments/**')
  
  scrape: ->
    if id = @uri.path.match(COMMENT_PATTERN)?[1]
      $.getJSON "http://reddit.com/by_id/t1_#{id}.json", (response) =>
        comment = response.data.children[0].data
        # TODO show comment snippet
        @pass()
    else if id = @uri.path.match(POST_PATTERN)?[1]
      $.ajax "http://reddit.com/by_id/t3_#{id}.json",
        type: 'get', dataType: 'json', error: @pass
        success: (response) =>
          @createPostPreview response.data.children[0].data
    else
      @cancel()
  
  createPostPreview: (post) ->
    if post.thumbnail.charAt(0) is '/'
      thumbnail = "http://#{@uri.host}#{post.thumbnail}"
    else
      thumbnail = post.thumbnail
    
    preview = @createPreview(
      uri: "http://#{@uri.host}#{post.permalink}"
      title: post.title
      snippet: @createPostSnippet(post)
      thumbnail: thumbnail )
    .addClass('gg-redditPreview')
    
    # override thumbnail link :O
    $('.gg-previewThumbnail a', preview).attr href: post.url
  
  createPostSnippet: (post) ->
    snippet = $(SNIPPET_TEMPLATE)
    
    timestamp = new Date(post.created * 1000)
    
    $('.gg-redditPreviewDomain', snippet)
    .attr(
      href: "http://#{@uri.host}/domain/#{post.domain}",
      title: "Find all posts from #{post.domain} on Reddit" )
    .text(post.domain)
    
    $('.gg-redditPreviewKarma', snippet).text "#{post.score} karma"
    
    # TODO title => pretty date, text => "xxxx ago" date
    $('.gg-redditPreviewTimestamp', snippet)
    .attr(
      title: timestamp.toLocaleString(),
      datetime: timestamp.toISOString() )
    .text(timestamp.toLocaleString())
    
    $('.gg-redditPreviewAuthor', snippet)
    .attr(href: "http://#{@uri.host}/user/#{post.author}")
    .text(post.author)
    
    $('.gg-redditPreviewSubreddit', snippet)
    .attr(href: "http://#{@uri.host}/r/#{post.subreddit}")
    .text(post.subreddit)
    
    if post.is_self
      html = post.selftext_html.unescapeEntities()
      snippet.push $(html).children()...
    
    # make sure to return this!
    snippet
    