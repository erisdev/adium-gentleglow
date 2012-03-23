{BasicScraper} = require 'preview'
resources = require 'resources'

exports = class TumblrScraper extends BasicScraper
  @API_KEY = require('message_style')['api-keys'].tumblr
  POST_PATTERN = ///^ /post/ (\d+) /? ///
  
  @doesUriMatch: (uri) ->
    @API_KEY? and uri.isInDomain('tumblr.com') and uri.path.match(POST_PATTERN)?
  
  scrape: ->
    if id = @uri.path.match(POST_PATTERN)?[1]
      api_key = TumblrScraper.API_KEY
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
      snippet: post.body
      thumbnail: this.createBlogThumbnail(blog)
  
  # Photo Posts
  ##
  
  createPhotoPreview: (post, blog) ->
    if post.photos.length > 1
      photoset = true
      title = "photoset"
    else
      photoset = false
      title = "photo"
    
    photo = post.photos[0].alt_sizes[0]
    
    for thumbnail in post.photos[0].alt_sizes
      break if thumbnail.width < 200 or thumbnail.height < 200
    
    this.createPreview
      uri: post.post_url
      title: this.createPostTitle(title, blog)
      # TODO pick a suitably sized thumbnail image
      thumbnail: thumbnail.url
      snippet: post.caption
      dimensions: [photo.width, photo.height]
  
  # Quote Posts
  ##
  
  createQuotePreview: (post, blog) ->
    this.createPreview
      uri: post.post_url
      title: this.createPostTitle(post.text, blog)
      # TODO create quote snippet with attribution
      snippet: post.text
      thumbnail: this.createBlogThumbnail(blog)
  
  # Link Posts
  ##
  
  createLinkPreview: (post, blog) ->
    this.createPreview
      uri: post.post_url
      title: this.createPostTitle(post.title, blog)
      snippet: post.description
      thumbnail: this.createBlogThumbnail(blog)
  
  # Chat Posts
  ##
  
  createChatPreview: (post, blog) ->
    if post.title? and post.title.length > 0
      title = post.title
    else
      title = "chat transcript"
    
    this.createPreview
      uri: post.post_url
      title: this.createPostTitle(title, blog)
      thumbnail: this.createBlogThumbnail(blog)
      snippet: resources.render('views/tumblr/chat', dialogue: post.dialogue)
  
  # Audio Posts
  ##
  
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
      thumbnail: this.createBlogThumbnail(blog)
      snippet: post.caption
      embed: post.player
  
  # Video Posts
  ##
  
  createVideoPreview: (post, blog) ->
    this.createPreview
      uri: post.post_uri
      title: this.createPostTitle('video', blog)
      thumbnail: this.createBlogThumbnail(blog)
      snippet: post.caption
      embed: post.player[0].embed_code
  
  # Answer Posts
  ##
  
  createAnswerPreview: (post, blog) ->
    this.createPreview
      uri: post.post_uri
      title: this.createPostTitle("question from #{post.asking_name}", blog)
      thumbnail: this.createBlogThumbnail(blog)
      snippet: resources.render 'views/tumblr/answer',
        asker: { name: post.asking_name, uri: post.asking_uri }
        question: post.question
        answer: post.answer
  
  # Utility Functions
  ##
  
  createBlogThumbnail: (blog) -> "http://api.tumblr.com/v2/blog/#{@uri.host}/avatar/128"
  createPostTitle: (title, blog) -> "#{blog.title}: #{title}"
