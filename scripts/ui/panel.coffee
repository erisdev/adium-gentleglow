resources = require 'resources'
UIBase = require 'ui/base'

exports = class UIPanel extends UIBase
  @property 'title', '.ui-panelHeader'
  
  constructor: (contentTemplate, options = {}) ->
    super 'views/ui/panel', options
    
    @title = options.title ? 'Panel'
    
    contentHtml = resources.render contentTemplate, options.parameters
    $(@rootElement).children('.ui-panelContent').html contentHtml
  
  show: (options) ->
    el = $(@rootElement)
    el.appendTo('body') unless @rootElement.parentElement?
    el.cssFadeIn()
  
  hide: ->
    $(@rootElement).cssFadeOut()
