class ImgurScraper extends Preview.ThumbnailScraper
  Preview.register this
  
  @doesUriMatch: (uri) ->
    if uri.host is 'imgur.com' or uri.host is 'i.imgur.com'
      isAlbum = uri.globPath '/a/**'
      not isAlbum or (isAlbum and uri.fragment?)
    else
      false
  
  loadPreview: ->
    if @uri.globPath('/a/**')
      id = @uri.fragment
    else
      id = @uri.path.match(/// ([^/\.]+) (?: \. [^/\.]+ )? $ ///)?[1]
    
    if id?
      $.getJSON("http://api.imgur.com/2/image/#{id}", (data) =>
        @setPreviewTitle data.image.image.title ? @source.text()
        @setPreviewImage data.image.links.small_square
        @setPreviewLink data.image.links.imgur_page
      )
      .error => @cancel()
