class AnyImageScraper extends Preview.ThumbnailScraper
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
  
  loadPreview: ->
    $.ajax @uri.toString(),
      type: 'HEAD'
      success: (_, status, response) =>
        contentType = response.getResponseHeader 'Content-Type'
        contentLength = response.getResponseHeader 'Content-Length'
        if contentType in IMAGE_TYPES
          if contentLength < MAX_DOWNLOAD_SIZE
            @setPreviewImage @uri
          else
            @setPreviewImage 'images/camera.png'
          @setPreviewTitle @uri.path.split('/').pop()
        else
          @cancel()
      error: =>
        @cancel()
