unescapeEntities = (str) ->
  # Ugh, dirty hax. Why doesn't JavaScript come with this?
  $('<div>').html(str).text()

class RedditScraper extends Preview.BasicScraper
  Preview.register this
  
  COMMENT_PATTERN = ///^ /r/ [^/]+ /comments/ [a-z0-9]+ / [^/]+ / ([a-z0-9]+) ///
  POST_PATTERN    = ///^ /r/ [^/]+ /comments/ ([a-z0-9]+) ///i
  
  POST_META_TEMPLATE = '''
    <p class="reddit-meta">
      (<a class="reddit-domain">example.com</a>)
      <span class="reddit-karma">37 karma</span>
      submitted <time class="reddit-timestamp" pubdate>ages ago</time>
      by <a class="reddit-author">nobody</a>
      to <a class="reddit-subreddit">subreddit</a>
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
      thumbnail: thumbnail )
    .addClass('reddit')
    
    # remove content paragraph; this will be replaced with our own content.
    $('.content', preview).remove()
    
    @createPostSnippet $('.snippet', preview), post
    
    # override thumbnail link :O
    $('.thumbnail a', preview).attr href: post.url
  
  createPostSnippet: (snippet, post) ->
    meta = $(POST_META_TEMPLATE).appendTo(snippet)
    
    timestamp = new Date(post.created * 1000)
    
    $('.reddit-domain', meta)
    .attr(
      href: "http://#{@uri.host}/domain/#{post.domain}",
      title: "Find all posts from #{post.domain} on Reddit" )
    .text(post.domain)
    
    $('.reddit-karma', meta).text "#{post.score} karma"
    
    # TODO title => pretty date, text => "xxxx ago" date
    $('.reddit-timestamp', meta)
    .attr(
      title: timestamp.toLocaleString(),
      datetime: timestamp.toISOString() )
    .text(timestamp.toLocaleString())
    
    $('.reddit-author', meta)
    .attr(href: "http://#{@uri.host}/user/#{post.author}")
    .text(post.author)
    
    $('.reddit-subreddit', meta)
    .attr(href: "http://#{@uri.host}/r/#{post.subreddit}")
    .text(post.subreddit)
    
    if post.is_self
      html = unescapeEntities post.selftext_html
      $(html).addClass('content').appendTo(snippet)
    
    # make sure to return this!
    meta
    