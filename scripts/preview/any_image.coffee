class AnyImageScraper extends Preview.ThumbnailScraper
  Preview.register this
  
  PATTERN = /// \. (?: bmp | gif | jp2 | jpe?g | png | tiff? ) $///i
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
        if contentType in IMAGE_TYPES
          @setPreviewImage 'images/camera.png'
          @setImageTitle @uri.path.split('/').pop()
        else
          @cancel()
      error: => @cancel()
