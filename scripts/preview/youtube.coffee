createXPathFunction = (xml, defaultNamespace) ->
  # jump through hoops for the XPath API
  resolver = (ns) ->
    if ns is defaultNamespace
      xml.documentElement.namespaceURI
    else
      xml.lookupNamespaceURI ns
  
  (query) -> xml.evaluate(query, xml, resolver, XPathResult.STRING_TYPE, null).stringValue

class YouTubeScraper extends Preview.ThumbnailScraper
  Preview.register this
  
  @doesUriMatch: (uri) ->
    if uri.isInDomain 'youtube.com'
      uri.query.v? or
      uri.globPath '/v/*'
    else
      uri.host is 'youtu.be'
  
  scrape: ->
    if @uri.host is 'youtu.be'
      id = @uri.path.substring 1
    else
      id = @uri.query.v ? @uri.path.match(///^ /v/ (.*) ///)?[1]
    
    if id?
      $.ajax "https://gdata.youtube.com/feeds/api/videos/#{id}?v=2",
        type: 'get', dataType: 'xml', error: @pass
        success: (xml) =>
          xpath = createXPathFunction(xml, 'atom')
          @createPreview
            title:     xpath '/atom:entry/atom:title'
            thumbnail: xpath '/atom:entry/media:group/media:thumbnail[@yt:name="default"]/@url'
    else
      @pass()
