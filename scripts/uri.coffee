
isEmptyObject = (object) ->
  for own key of object
    return false
  true

class Uri
  PARSER =
    # These horrifying, fabulous regexps are modified from Steven Levithan's
    # equally horrifying and fabulous parseUri version 1.2.2.
    keys: ['protocol', 'user', 'password', 'host', 'port', 'path', 'query', 'fragment']
    strict: /^(?:([^:\/?\#]+):)?(?:\/\/(?:(?:([^:@]*)(?::([^:@]*))?)?@)?([^:\/?\#]*)(?::(\d*))?)?((?:[^?\#]*)*)(?:\?([^\#]*))?(?:\#(.*))?/
    loose:  /^(?:(?![^:@]+:[^:@\/]*@)([^:\/?\#.]+):)?(?:\/\/)?(?:(?:([^:@]*)(?::([^:@]*))?)?@)?([^:\/?\#]*)(?::(\d*))?((?:\/(?:[^?\#](?![^?\#\/]*\.[^?\#\/.]+(?:[?\#]|$)))*\/?)?)(?:\?([^\#]*))?(?:\#(.*))?/
    query:  /(?:^|[&;])([^&;=]*)=?([^&;]*)/g
  
  constructor: (uri, options)->
    parts = Uri.split uri
    for key, index in PARSER.keys when key isnt 'query'
      @[key] = parts[index]
    
    @query = Uri.parseQueryString parts[PARSER.keys.indexOf 'query']
  
  getQueryString: ->
    if @query?
      Uri.createQueryString @query
    else
      null
  
  matchHost: (query) ->
    if query is @host
      true
    else if query.length > @host.length
      false
    else
      i = @host.lastIndexOf query
      i is @host.length - query.length and
        @host.charAt(i - 1) is '.'
  
  matchPath: (query) ->
    if query is @path
      true
    else if query.length > @path.length
      false
    else
      query is @path.substring(0, query.length)
  
  toString: (context) ->
    string = ''
    string += "#{@protocol}:" if @protocol?
    
    if @host?
      string += '//'
      
      if @user?
        string += @user
        string += ":#{@password}" if @password?
        string += '@'
      
      string += @host
      string += ":#{@port}" if @port?
      string += '/'
    
    if @path?
      if @host?
        string += @path.replace /^\//, ''
      else
        string += @path
    
    string += "?#{@getQueryString()}" unless isEmptyObject(@query)
    string += "##{@fragment}" if @fragment?
    
    string
    
  @split: (uriString = '', strict = true) ->
    parser = PARSER[if strict then 'strict' else 'loose']
    for part, index in parser.exec(uriString)[1..-1]
      if part? and part isnt '' then part else null
  
  @parseQueryString: (queryString) ->
    query = { }
    queryString?.replace PARSER.query, (m, key, value) ->
      query[key] = value
    query
  
  @createQueryString: (object) ->
    components = [ ]
    for own key, value of object
      if object instanceof Array
        for subvalue in object
          components.push "#{encodeURIComponent key}[]=#{encodeURIComponent subvalue}"
      else
        components.push "#{encodeURIComponent key}=#{encodeURIComponent value}"
    components.join '&'

window.Uri = Uri
