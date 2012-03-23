{BasicScraper} = require 'preview'

exports = class MagnetScraper extends BasicScraper
  @doesUriMatch: (uri) ->
    uri.scheme is 'magnet'
  
  scrape: ->
    if @uri.files.length > 0
      this.createPreview 'views/magnet', uri: @uri
    else
      this.pass()
