class TumblrScraper extends Preview.BasicScraper
  Preview.register this
  
  POST_PATTERN = ///^ /post/ (\d+) /? ///
  
  @doesUriMatch: (uri) ->
    uri.isInDomain('tumblr.com') and uri.path.match(POST_PATTERN)?
  
  scrape: ->
    api_key = MessageStyle['api-keys'].tumblr
    if id = @uri.path.match(POST_PATTERN)?[1]
      this.ajax "http://api.tumblr.com/v2/blog/#{@uri.host}/posts", { id, api_key }, (json) =>
        post = json.response.posts[0]
        blog = json.response.blog
        switch post.type
          when 'text'   then this.createTextPreview(post, blog)
          when 'photo'  then this.createPhotoPreview(post, blog)
          when 'quote'  then this.createQuotePreview(post, blog)
          when 'link'   then this.createLinkPreview(post, blog)
          when 'chat'   then this.createChatPreview(post, blog)
          when 'audio'  then this.createAudioPreview(post, blog)
          when 'video'  then this.createVideoPreview(post, blog)
          when 'answer' then this.createAnswerPreview(post, blog)
          else this.pass()
    else
      this.ajax "http://api.tumblr.com/v2/blog/#{@uri.host}/info", { id, api_key }, (json) =>
        this.createBlogPreview(json.response.blog)
  
  createBlogPreview: (blog) ->
    this.createPreview
      uri: blog.url
      title: blog.title
      snippet: $(blog.description)
      thumbnail: this.createBlogThumbnail(blog)
  
  # Text Posts
  ##
  
  createTextPreview: (post, blog) ->
    this.createPreview
      uri: post.post_url
      title: this.createPostTitle(post.title, blog)
      snippet: $(post.body)
      thumbnail: this.createBlogThumbnail(blog)
  
  # Photo Posts
  ##
  
  createPhotoPreview: (post, blog) ->
    if post.photos.length > 1
      title = "photoset"
    else
      title = "photo"
    
    this.createPreview
      uri: post.post_url
      title: this.createPostTitle(title, blog)
      snippet: $(post.caption)
      # TODO pick a suitably sized thumbnail image
      thumbnail: post.photos[0].alt_sizes[0].url
  
  # Quote Posts
  ##
  
  createQuotePreview: (post, blog) ->
    this.createPreview
      uri: post.post_url
      title: this.createPostTitle(post.text, blog)
      # TODO create quote snippet with attribution
      snippet: $(post.text)
      thumbnail: this.createBlogThumbnail(blog)
  
  # Link Posts
  ##
  
  createLinkPreview: (post, blog) ->
    this.createPreview
      uri: post.post_url
      title: this.createPostTitle(post.title, blog)
      snippet: $(post.description)
      thumbnail: this.createBlogThumbnail(blog)
  
  # Chat Posts
  ##
  
  CHAT_TEMPLATE = '<ul class="tumblr-chat"></ul>'
  CHAT_LINE_TEMPLATE = '''
    <li>
      <span class="tumblr-chat-name"></span>:
      <span class="tumblr-chat-text"></span>
    </li>
  '''
  
  createChatPreview: (post, blog) ->
    if post.title? and post.title.length > 0
      title = post.title
    else
      title = "chat transcript"
    
    this.createPreview
      uri: post.post_url
      title: this.createPostTitle(title, blog)
      snippet: this.createChatSnippet(post, blog)
      thumbnail: this.createBlogThumbnail(blog)
  
  createChatSnippet: (post, blog) ->
    $(CHAT_TEMPLATE).tap (chatSnippet) ->
      for line in post.dialogue
        lineSnippet = $(CHAT_LINE_TEMPLATE).appendTo(chatSnippet)
        $('.tumblr-chat-name', lineSnippet).text line.name
        $('.tumblr-chat-text', lineSnippet).text line.phrase
      return
  
  # Audio Posts
  ##
  
  AUDIO_TEMPLATE = '''
    <div class="tumblr-audio">
      <div class="tumblr-player"></div>
      <div class="tumblr-caption"></div>
    </div>
  '''
  
  createAudioPreview: (post, blog) ->
    if post.artist? and post.track_name?
      title = "\"#{post.track_name}\" by #{post.artist}"
    else if post.track_name?
      title = "\"#{post.track_name}\""
    else
      title = "audio"
    
    this.createPreview
      uri: post.post_url
      title: this.createPostTitle(title, blog)
      snippet: this.createAudioSnippet(post, blog)
      thumbnail: this.createBlogThumbnail(blog)
  
  createAudioSnippet: (post, blog) ->
    $(AUDIO_TEMPLATE).tap (snippet) ->
      # TODO figure out how to embed audio
      # $('.tumblr-player',  snippet).html post.player
      $('.tumblr-caption', snippet).html post.caption
  
  # Video Posts
  ##
  
  VIDEO_TEMPLATE = '''
    <div class="tumblr-audio">
      <div class="tumblr-player"></div>
      <div class="tumblr-caption"></div>
    </div>
  '''
  
  createVideoPreview: (post, blog) ->
    this.createPreview
      uri: post.post_uri
      title: this.createPostTitle('video', blog)
      snippet: this.createVideoSnippet(post, blog)
      thumbnail: this.createBlogThumbnail(blog)
  
  createVideoSnippet: (post, blog) ->
    $(VIDEO_TEMPLATE).tap (snippet) ->
      # TODO figure out how to embed video
      # $('.tumblr-player',  snippet).html post.player[0].embed_code
      $('.tumblr-caption', snippet).html post.caption
  
  # Answer Posts
  ##
  
  ANSWER_TEMPLATE = '''
    <div class="tumblr-qa">
      <p><a class="tumblr-asker">somebody</a> asked:</p>
      <blockquote class="tumblr-question">what do?</blockquote>
      <div class="tumblr-answer"></div>
    </div>
  '''
  
  createAnswerPreview: (post, blog) ->
    this.createPreview
      uri: post.post_uri
      title: this.createPostTitle("question from #{post.asking_name}", blog)
      snippet: this.createAnswerSnippet(post, blog)
      thumbnail: this.createBlogThumbnail(blog)
  
  createAnswerSnippet: (post, blog) ->
    $(ANSWER_TEMPLATE).tap (snippet) ->
      $('.tumblr-asker', snippet)
        .attr(href: post.asking_url)
        .text(post.asking_name)
      
      $('.tumblr-question', snippet).html post.question
      $('.tumblr-answer',   snippet).html post.answer
  
  # Utility Functions
  ##
  
  createBlogThumbnail: (blog) -> "http://api.tumblr.com/v2/blog/#{@uri.host}/avatar/128"
  createPostTitle: (title, blog) -> "#{blog.title}: #{title}"
