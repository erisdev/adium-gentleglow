resources = require 'resources'

exports = class UIMenu
  constructor: (@title, options, buildMenu) ->
    if not buildMenu? and typeof options is 'function'
      [options, buildMenu] = [{}, options]
    else if not options?
      options = {}
    
    @items = []
    @itemTemplate = options.itemTemplate ? 'views/ui/menu/item'
    @temporary = options.temporary ? false
    
    if buildMenu?
      buildMenu
        item: =>
          @addItem.apply this, arguments
        separator: =>
          @addSeparator.apply this, arguments
  
  addItem: (label, options, action) ->
    if not action? and typeof options is 'function'
      [options, action] = [{}, options]
    
    item = $.extend {label, action}, options
    item.id ?= Math.uuid()
    
    if contentElement = @rootElement?.find('.ui-menuContent')
      this.renderItem contentElement, item
    
    @items.push item
  
  addSeparator: ->
    @items.push {}
  
  render: ->
    html = resources.render 'views/ui/menu/menu', this
    @rootElement = $(html).data(ui: this).hide().appendTo 'body'
    
    content = @rootElement.find '.ui-menuContent'
    this.renderItem(content, item) for item in @items
  
  renderItem: (content, item)->
    html = resources.render @itemTemplate, item
    $(html).bind 'click', (event) =>
      item.action.call event.target, event
      this.hide()
    .appendTo content
  
  toggle: (pos) ->
    if @rootElement?.is(':visible')
      this.hide()
    else
      this.show pos
  
  show: (targetPos = {}) ->
    unless @rootElement?
      this.render()
    
    cssPos = {}
    height = @rootElement.outerHeight()
    width  = @rootElement.outerWidth()
    
    if targetPos.at?
      # position relative to another element
      {left: x, top: y} = $(targetPos.at).offset()
      x += targetPos.x if targetPos.x?
      y += targetPos.y if targetPos.y?
    else
      # position absolutely
      {x, y} = targetPos
    
    if x + width <= window.innerWidth
    then [cssPos.left,  cssPos.right] = [x, '']
    else [cssPos.right, cssPos.left ] = [window.innerWidth - x, '']
    
    if y + height <= window.innerHeight
    then [cssPos.top,    cssPos.bottom] = [y, '']
    else [cssPos.bottom, cssPos.top   ] = [window.innerHeight - y, '']
    
    @rootElement.css(cssPos).cssFadeIn() unless @rootElement.is ':visible'
  
  hide: ->
    @rootElement?.cssFadeOut =>
      this.destroy() if @temporary
  
  destroy: ->
    @rootElement.remove()
    @rootElement = null
