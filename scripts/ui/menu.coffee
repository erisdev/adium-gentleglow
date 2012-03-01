resources = require 'resources'

exports = class UIMenu
  constructor: (@title, options, buildMenu) ->
    [options, buildMenu] = [{}, options] unless buildMenu?
    
    @items = []
    @temporary = options.temporary ? false
    
    buildMenu
      item: (label, action) =>
        @items.push {label, action, id: Math.uuid()}
      separator: =>
        @items.push label: '-'
  
  toggle: (x, y) ->
    if @rootElement?.is(':visible')
      this.hide()
    else
      this.show x, y
  
  show: (x, y) ->
    unless @rootElement?
      html = resources.render 'views/ui/menu', this
      @rootElement = $(html).data(ui: this).hide().appendTo 'body'
      for item in @items then do (item) =>
        item.element = @rootElement
        .find(".ui-menuItem##{item.id}")
        .bind 'click', (event) =>
          this.hide()
          item.action?.call event.target, event
    
    pos = {top: '', right: '', bottom: '', left: ''}
    height = @rootElement.outerHeight()
    width  = @rootElement.outerWidth()
    
    if x + width <= window.innerWidth
      pos.left = x
    else
      pos.right = window.innerWidth - x
    
    if y + height <= window.innerHeight
      pos.top = y
    else
      pos.bottom = window.innerHeight - y
    
    @rootElement.css(pos).cssFadeIn() unless @rootElement.is ':visible'
  
  hide: ->
    @rootElement?.cssFadeOut =>
      this.destroy() if @temporary
  
  destroy: ->
    @rootElement.remove()
    @rootElement = null
