$.model ?= {}

class $.model.BaseModel
  constructor: (source, options = {}) ->
    el = $(source).data(model: this)
    [@rootElement] = el
    
    el.attr id: options.id if options.id?
    
    this.load $.extend({}, el.data('model-options'), options)
  
  load: (options) ->
  
  find: (selector) ->
    if selector?
    then $(@rootElement).find selector
    else $(@rootElement)
  
  destroy: ->
    $(@rootElement).remove()
  
  Object.defineProperty @prototype, 'id',
    enumerable: true
    get: ->
      unless uuid = $(@rootElement).attr 'id'
        uuid = Math.uuid()
        $(@rootElement).attr id: uuid
      uuid
  
  @property: (name, selector, attr = 'text') ->
    options = switch attr
      when 'text'
        get:       -> $(@rootElement).find(selector).text()
        set: (val) -> $(@rootElement).find(selector).text val
      when 'html'
        get:       -> $(@rootElement).find(selector).html()
        set: (val) -> $(@rootElement).find(selector).html val
      else
        get:       -> $(@rootElement).find(selector).attr attr
        set: (val) -> $(@rootElement).find(selector).attr attr, val
    
    options = $.extend options, enumerable: true
    Object.defineProperty @prototype, name, options

wrap = (el) ->
  $el = $(el)
  unless model = $el.data 'model'
    className = $el.data 'className'
    return null unless className? and className of $.model
    model = Object.create $.model[className].prototype
    model.rootElement = el
    model.load $el.data 'model-options'
    $el.data {model}
  model

$.fn.model = -> wrap this[0]
$.fn.models = -> wrap el for el in this
