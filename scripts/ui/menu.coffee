resources = require 'resources'
UIBase = require 'ui/base'

UIMenuSeparator = class $.model.UIMenuSeparator extends UIBase
  constructor: -> super $('<li class="ui-menuSeparator">')

UIMenuItem = class $.model.UIMenuItem extends UIBase
  constructor: (options, @action) ->
    super options.template ? 'views/ui/menu/item', options
    
    $(@rootElement).bind 'click', (event) =>
      this.action?(event)
      $(event.target).closest('.ui-menu').model().hide()

exports = class $.model.UIMenu extends UIBase
  @property 'title', '.ui-menuHeader'
  
  constructor: (title, options, buildMenu) ->
    if not buildMenu? and typeof options is 'function'
      [options, buildMenu] = [{}, options]
    else if not options?
      options = {}
    
    super 'views/ui/menu', $.extend({title}, options)
    
    if buildMenu?
      buildMenu
        defaults: (options) =>
          $.extend @defaults, options
        item: =>
          this.addItem arguments...
        separator: =>
          this.addSeparator arguments...
  
  Object.defineProperty @prototype, 'items',
    get: -> this.find('.ui-menuItem, .ui-menuSeparator').models()
  
  load: (options) ->
    @defaults = $.extend {}, options.defaults
  
  addItem: (label, options, action) ->
    if not action? and typeof options is 'function'
      [options, action] = [{}, options]
    
    options = $.extend {label}, @defaults, options
    
    this.find('.ui-menuContent').append \
      new UIMenuItem(options, action).rootElement
  
  addSeparator: ->
    this.find('.ui-menuContent').append new UIMenuSeparator().rootElement
  
  show: (targetPos = {}) ->
    el = $(@rootElement)
    el.appendTo('body') unless @rootElement.parentElement?
    
    cssPos = {}
    height = el.outerHeight()
    width  = el.outerWidth()
    
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
    
    el.css(cssPos).cssFadeIn()
