class YouTubeScraper extends Preview.ThumbnailScraper
  Preview.register this
  
  @doesUriMatch: (uri) ->
    if uri.isInDomain 'youtube.com'
      uri.query.v? or
      uri.globPath '/v/*'
    else
      uri.host is 'youtu.be'
  
  loadPreview: ->
    if @uri.host is 'youtu.be'
      id = @uri.path.substring 1
    else
      id = @uri.query.v ? @uri.path.match(///^ /v/ (.*) ///)?[1]
    
    if id?
      $.get("https://gdata.youtube.com/feeds/api/videos/#{id}?v=2", (xml) =>
        # jump through hoops for the XPath API
        resolver = (ns) ->
          if ns is 'atom'
            xml.documentElement.namespaceURI
          else
            xml.lookupNamespaceURI ns
        xpath = (query) -> xml.evaluate(query, xml, resolver, XPathResult.STRING_TYPE, null).stringValue
        
        @setPreviewImage xpath '/atom:entry/media:group/media:thumbnail[@yt:name="default"]/@url'
        @setPreviewTitle xpath '/atom:entry/atom:title'
        @setPreviewLink @uri
      )
      .error => @cancel()
