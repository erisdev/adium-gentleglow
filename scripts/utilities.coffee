
Object.notImplemented = (constructor, method) ->
  constructor::[method] = -> throw new Error "Method #{method} must be implemented by #{constructor}"

Object::tap = (fn) ->
  fn(this)
  this

Object::isEmpty = ->
  for own key of this
    return false
  true

Number::toPaddedString = (length, base = 10) ->
  string = this.toString(base)
  string = "0#{string}" while string.length < length
  string

RegExp.escape = (string) ->
  string.replace /[\/\.\*\+\?\|\(\)\[\]\{\}\\]/g, '\\$&'

String::template = (params) ->
    pattern = /// \#\{ \s* ([a-z0-9_]+) \s* \} | \$ (\d+) ///ig
    this.replace pattern, (m, key, index) ->
      switch m.charAt 0
        when '#' then params[key]
        when '$' then params[parseInt index]
        else          'undefined'

# Ugh, dirty hax. Why doesn't JavaScript come with this?
String::escapeEntities   = -> $('<div>').text("#{this}").html()
String::unescapeEntities = -> $('<div>').html("#{this}").text()

hideProperties = (obj, properties...) ->
  for prop in properties
    Object.defineProperty obj, prop, enumerable: false 

hideProperties Object.prototype, 'tap', 'isEmpty'
hideProperties Number.prototype, 'toPaddedString'
hideProperties String.prototype, 'template', 'escapeEntities', 'unescapeEntities'