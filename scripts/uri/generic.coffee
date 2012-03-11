compilePathGlob = (pattern) ->
  parsedPattern = pattern.replace /// \*\*/? | [\*\?.+] ///g, (wc)->
    switch wc
      when '?'   then '[^/]'
      when '*'   then '[^/]*'
      when '**'  then '.*'
      when '**/' then '(?:[^/]+/)*'
      else RegExp.escape wc
  new RegExp "^#{parsedPattern}$"

compileDomainPattern = (domain) ->
  new RegExp "(?:^|\.)#{RegExp.escape domain}$"

exports = class Generic
  constructor: (uri) ->
    @defaultPort ?= null
    
    { @scheme, @userInfo, @host, @port,
      @registry, @path, @opaque, @query, @fragment } = uri
  
  isInDomain: (domain) ->
    if not @host or @host.length < domain.length
      false
    if domain is @host
      true
    else
      compileDomainPattern(domain).test @host
  
  globPath: (query) ->
    if query is @path
      true
    else
      compilePathGlob(query).test @path
  
  toString: ->
    out = []
    
    out.push "#{@scheme}:" if @scheme?
    
    if @opaque?
      out.push @opaque
    else
      if @registry?
        out.push @registry
      else
        out.push '//'            if @host?
        out.push "#{@userInfo}@" if @userInfo?
        out.push @host           if @host?
        out.push ":#{@port}"     if @port? and @port isnt @defaultPort
      
      out.push @path ? '/'
      out.push "?#{@query}" if @query
    
    out.push "##{@fragment}" if @fragment?
    out.join ''