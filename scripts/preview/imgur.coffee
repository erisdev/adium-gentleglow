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
      $.ajax "http://api.imgur.com/2/image/#{id}",
        type: 'get', dataType: 'json', error: @pass
        success: (data) =>
          { image, links } = data.image
          @createPreview
            uri: links.imgur_page
            title: image.title
            thumbnail: links.small_square
    else
      @pass()
