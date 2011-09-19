class RedditScraper extends Preview.SummaryScraper
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
  
  loadPreview: ->
    console.log @uri
    if id = @uri.path.match(COMMENT_PATTERN)?[1]
      $.getJSON "http://reddit.com/by_id/t1_#{id}.json", (response) =>
        comment = response.data.children[0].data
        console.log comment
        # TODO show comment snippet
        
    else if id = @uri.path.match(POST_PATTERN)?[1]
      $.getJSON "http://reddit.com/by_id/t3_#{id}.json", (response) =>
        post = response.data.children[0].data
        console.log post
        
        timestamp = new Date(post.created * 1000)
        
        if post.thumbnail.charAt(0) is '/'
          thumbnail = "http://#{@uri.host}#{post.thumbnail}"
        else
          thumbnail = post.thumbnail
        
        @preview.addClass 'reddit'
        meta = $(POST_META_TEMPLATE).insertAfter $('.title', @preview)
        
        $('.thumbnail a',   @preview).attr href: post.url
        $('.thumbnail img', @preview).attr src: thumbnail
        
        $('.title a', @preview)
        .attr(
          href: "http://#{@uri.host}#{post.permalink}",
          title: post.title )
        .text(post.title)
        
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
          # Ugh, dirty hax. Why doesn't JavaScript come with this?
          selftext = $('<div>').html(post.selftext_html).text()
          $('.content', @preview)
          .replaceWith(
            $('<div>')
            .addClass('content')
            .html(selftext) )
      
    else
      @cancel()
