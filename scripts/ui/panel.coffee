resources = require 'resources'

exports = class UIPanel
  constructor: (contentTemplate, options = {}) ->
    options = $.extend {}, options
    
    @parameters = options.parameters ? {}
    @id = options.id ? Math.uuid()
    @title = options.title ? 'Panel'
    
    @templates =
      panel: resources.get 'views/ui/panel'
    
    if typeof contentTemplate is 'function'
      @templates.content = contentTemplate
    else
      @templates.content = resources.get(contentTemplate)
  
  load: ->
    parameters = $.extend {@title}, @parameters
    
    rootHtml = @templates.panel parameters
    contentHtml = @templates.content parameters
    
    @rootElement = $(rootHtml).hide().attr({@id}).appendTo 'body'
    @rootElement.children('.ui-panelContent').html contentHtml
    
    # promote header, content and footer elements from the content template
    for className in ['ui-panelHeader', 'ui-panelFooter', 'ui-panelContent']
      @rootElement.find(".ui-panelContent > .#{className}").each (i, el) ->
        console.log ""
        $(el).closest('.ui-panel').children(".#{className}").replaceWith el
    
    $(this).trigger jQuery.Event('ui:load', {ui: this, @rootElement})
  
  isVisible: ->
    if @rootElement?
      @rootElement.is(':visible')
    else
      false
  
  toggle: (options = {}) ->
    if this.isVisible()
      this.hide options
    else
      this.show options
  
  show: ->
    this.load() unless @rootElement?
    @rootElement.cssFadeIn()
  
  hide: (options = {}) ->
    panel = this
    @rootElement?.cssFadeOut ->
      if options.destroy
        $(this).remove()
        panel.rootElement = null
