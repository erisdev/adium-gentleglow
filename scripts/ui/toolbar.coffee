resources = require 'resources'

require 'jquery/model'

class jQuery.model.UIToolbarButton extends $.model.BaseModel
  @property 'label', '.ui-toolbarButtonLabel', 'text'
  @property 'badge', '.ui-toolbarButtonBadge', 'text'
  
  Object.defineProperty @prototype, '_icon', enumerable: false, value: null
  Object.defineProperty @prototype, 'icon',
    enumerable: true
    get: -> @_icon
    set: (@_icon) ->
      $(@rootElement).css backgroundImage: """url("images/icons/#{@_icon}.png")"""

buttons = {}

exports.addButton = (label, options, action) ->
  if not action? and typeof options is 'function'
    [options, action] = [{}, options]
  
  options = $.extend {label}, options
  html = resources.render 'views/ui/toolbar/button', options
  
  $(html).on 'click', (event) ->
    $(this).model().action? event
  .appendTo('#gg-toolbar')
  .model().tap (button) ->
    id = options.id ? label.toLowerCase().replace(/\s+/, '-')
    buttons[id] = button
    
    button.icon = options.icon ? 'page'
    button.action = action

exports.getButton = (id) -> buttons[id]
