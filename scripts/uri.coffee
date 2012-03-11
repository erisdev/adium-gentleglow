Generic = require 'uri/generic'
uriParser = require 'uri/parser'

registeredSchemes = {}

exports.register = register = (schemes..., constructor) ->
  for scheme in schemes
    scheme = scheme.toLowerCase()
    registeredSchemes[scheme] = constructor 

exports.parse = (str) ->
  if str instanceof Generic
    str # don't try to parse what's already a URI
  else if uri = uriParser.split("#{str}")
    scheme = uri.scheme.toLowerCase()
    uriConstructor = registeredSchemes[scheme] ? Generic
    new uriConstructor uri

register 'http', 'https', require('uri/http')
register 'magnet',        require('uri/magnet')
