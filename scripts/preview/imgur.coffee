class ImgurScraper extends Preview.BasicScraper
  Preview.register this
  
  SNIPPET_TEMPLATE = '''
    <p class="gg-previewInfo">
      <span class="imgur-dimensions">pretty small</span>
      (<span class="imgur-size">1337 bytes</span>)
      <span class="imgur-animated">animated</span>
      <span class="imgur-type">image/png</span>;
      <span class="imgur-views">some views</span>,
      uploaded <time class="imgur-timestamp" pubdate>some time ago</time>.
    </p>
    <p class="imgur-caption"></p>
  '''
  
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
            title: image.title ? "Imgur image #{image.hash}"
            snippet: @createSnippet(image)
            thumbnail: links.small_square
    else
      @pass()
  
  createSnippet: (image) ->
    snippet = $(SNIPPET_TEMPLATE)
    
    # TODO parse the date. why can't everyone just do it the right way?
    # timestamp = Date.parse image.datetime
    # $('.imgur-timestamp', snippet)
    #   .attr(
    #     title: timestamp.toLocaleString(),
    #     datetime: timestamp.toISOString() )
    #   .text(timestamp.toLocaleString())
    
    $('.imgur-views', snippet).text(
      switch image.views
        when 0 then "no views"
        when 1 then "one view"
        else        "#{image.views} views"
    )
    
    $('.imgur-caption', snippet).text(image.caption) if image.caption?
    
    # wtf, boolean strings?
    $('.imgur-animated', snippet).remove() unless image.animated is "true"
    
    $('.imgur-dimensions', snippet).text "#{image.width}\u00d7#{image.height}"
    $('.imgur-size',       snippet).text "#{image.size} bytes"
    $('.imgur-type',       snippet).text "#{image.type}"
    
    snippet