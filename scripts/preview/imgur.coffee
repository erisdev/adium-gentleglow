class ImgurScraper extends Preview.BasicScraper
  Preview.register this
  
  @doesUriMatch: (uri) ->
    if uri.host is 'imgur.com' or uri.host is 'i.imgur.com'
      isAlbum = uri.globPath '/a/**'
      not isAlbum or (isAlbum and uri.fragment?)
    else
      false
  
  scrape: ->
    if @uri.globPath('/a/**')
      id = @uri.fragment
    else
      id = @uri.path.match(/// ([^/\.]+) (?: \. [^/\.]+ )? $ ///)?[1]
    
    if id?
      this.ajax "http://api.imgur.com/2/image/#{id}.json", {}, (data) =>
        { image, links } = data.image
        @createPreview
          uri: links.imgur_page
          title: image.title ? "Imgur image #{image.hash}"
          thumbnail: links.small_square
          snippet: image.caption?.encodeEntities()
          dimensions: [image.width, image.height]
          size: image.size
          # wtf, boolean strings?
          animated: (image.animated is "true")
          fileType: image.type
          views: image.views
          timestamp: new Date Date image.datetime
    else
      @pass()
