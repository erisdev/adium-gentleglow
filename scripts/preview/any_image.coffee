class AnyImageScraper extends Preview.BasicScraper
  Preview.register this
  
  PATTERN = /// \. (?: bmp | gif | jp2 | jpe?g | png | tiff? ) $///i
  MAX_DOWNLOAD_SIZE = 5120
  IMAGE_TYPES = [
    'image/bmp', 'image/x-windows-bmp'
    'image/gif',
    'image/jpeg'
    'image/png',
    'image/tiff', 'image/x-tiff' ]
  
  @doesUriMatch: (uri) ->
    uri.path.match(PATTERN)?
  
  scrape: ->
    $.ajax @uri.toString(),
      type: 'head', error: @pass
      success: (_, status, response) =>
        contentType = response.getResponseHeader 'Content-Type'
        contentLength = response.getResponseHeader 'Content-Length'
        if  contentLength <  MAX_DOWNLOAD_SIZE \
        and contentType   in IMAGE_TYPES
          @createPreview thumbnail: "#{@uri}"
        else
          @pass()
