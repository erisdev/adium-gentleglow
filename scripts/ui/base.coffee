resources = require 'resources'

require 'jquery/model'

exports = class UIBase extends jQuery.model.BaseModel
  constructor: (template, options) ->
    super resources.render(template, options), options
  
  toggle: ->
    console.log this
    if $(@rootElement).is(':visible')
      this.hide arguments...
    else
      this.show arguments...
  
  show: (options) ->
    $(@rootElement).show()
  
  hide: ->
    $(@rootElement).hide()

