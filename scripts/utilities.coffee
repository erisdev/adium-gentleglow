
Object.notImplemented = (constructor, method) ->
  constructor::[method] = -> throw new Error "Method #{method} must be implemented by #{constructor}"

Object::tap = (fn) ->
  fn(this)
  this

Object::isEmpty = ->
  for own key of this
    return false
  true

Object::getKeys = -> key for key of this
Object::getOwnKeys = -> key for own key of this

Number::toPaddedString = (length, base = 10) ->
  string = this.toString(base)
  string = "0#{string}" while string.length < length
  string

RegExp.escape = (string) ->
  string.replace /[\/\.\*\+\?\|\(\)\[\]\{\}\\]/g, '\\$&'

getTemplateValue = (obj, keypath) ->
  keypath = keypath.split('.') if typeof keypath is 'string'
  key = keypath.shift()
  
  console.log obj, key, keypath
  
  if method = key.match(/^(.+)\(\)$/)?[1]
    value = obj[method].call(obj)
  else
    value = obj[key]
  
  if keypath.length > 0
    getTemplateValue value, keypath
  else
    value

String::hash = ->
  key = 0
  for i in [0...@length]
    key = (key << 4) + this.charCodeAt(i)
    g = key & 0xf0000000
    key ^= g >> 24 unless g is 0
    key &= ~g
  key

String::template = (params) ->
    pattern = /// \#\{ \s* ((?: [a-z0-9_\.] | \(\) )+) \s* \} | \$ (\d+) ///ig
    this.replace pattern, (m, key, index) ->
      switch m.charAt 0
        when '#' then getTemplateValue params, key
        when '$' then params[parseInt index]
        else          'undefined'

# Ugh, dirty hax. Why doesn't JavaScript come with this?
String::escapeEntities   = -> $('<div>').text("#{this}").html().replace('"', '&quot;').replace("'", '&apos;')
String::unescapeEntities = -> $('<div>').html("#{this}").text()

hideProperties = (obj, properties...) ->
  for prop in properties
    Object.defineProperty obj, prop, enumerable: false 

hideProperties Object.prototype, 'tap', 'isEmpty', 'getKeys', 'getOwnKeys'
hideProperties Number.prototype, 'toPaddedString'
hideProperties String.prototype, 'template', 'escapeEntities', 'unescapeEntities'