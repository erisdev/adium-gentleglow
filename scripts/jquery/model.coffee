$.model ?= {}

class $.model.BaseModel
  constructor: (@rootElement) ->
  
  find: (selector) ->
    if selector?
    then $(@rootElement).find selector
    else $(@rootElement)
  
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
  unless model = $(el).data 'model'
    className = $(el).data 'className'
    return null unless className
    return null unless className of $.model
    model = new $.model[className] el
    $(el).data {model}
  model

$.fn.model = -> wrap this[0]
$.fn.models = -> wrap el for el in this
