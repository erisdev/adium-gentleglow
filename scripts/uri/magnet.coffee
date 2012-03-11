Generic = require 'uri/generic'
uriParser = require 'uri/parser'

exports = class Magnet extends Generic
  constructor: (uri) ->
    super
    
    @files = []
    @otherParameters = {}
    
    for part in @opaque[1..].split('&') when part isnt ''
      [param, value] = part.split '=', 2
      
      if m = /^(.)\.(\d+)$/.exec(param)
        param = m[1]
        index = parseInt m[2]
      else
        index = 0
      
      file = @files[index] ?= {
        keywordTopic: []
        exactTopic: []
        exactSource: []
        addressTracker: []
      }
      
      switch param
        when 'dn' then file.displayName = decodeURIComponent value
        when 'xl' then file.exactLength = parseInt value
        when 'kt' then file.keywordTopic.push value.split('+')...
        when 'xt' then file.exactTopic.push value
        when 'xs' then file.exactSource.push value
        when 'tr' then file.addressTracker.push value
