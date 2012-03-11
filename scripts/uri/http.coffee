Generic = require 'uri/generic'

exports = class HTTP extends Generic
  PORTS = http: 80, https: 443
  constructor: (uri) ->
    super
    @defaultPort = PORTS[@scheme]
