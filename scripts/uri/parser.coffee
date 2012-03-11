# Taken from RFC 2396, URI Generic Syntax
(->
  @DIGIT          = "0-9"
  @ALPHA          = "A-Za-z"
  @ALPHANUM       = "#{@ALPHA}#{@DIGIT}"
  @MARK           = "\\-_\\.!~\\*'\\(\\)"
  @HEX            = "#{@DIGIT}A-Fa-f"
  @ESCAPED        = "%[#{@HEX}]{2}"
  @RESERVED       = ";/\\?:@&=\\+\\$,"
  @UNRESERVED     = "#{@ALPHANUM}#{@MARK}"
  @URIC           = "(?:[#{@RESERVED}#{@UNRESERVED}]|#{@ESCAPED})"
  @URIC_NO_SLASH  = "(?:[#{@UNRESERVED};\\?:@&=\\+\\$,]|#{@ESCAPED})"
  
  @SCHEME   = "(?<scheme>[#{@ALPHA}][#{@ALPHANUM}\\+\\-\\.]*)"
  
  @REG_NAME     = "(?<registry>(?:[#{@UNRESERVED}\\$,;:@&=\\+]|#{@ESCAPED})+)"
  @USERINFO     = "(?<userInfo>(?:[#{@UNRESERVED};:&=+\\$,]|#{@ESCAPED})*)"
  @DOMAIN_LABEL = "(?:[#{@ALPHANUM}]|[#{@ALPHANUM}](?:[#{@ALPHANUM}]|-)*[#{@ALPHANUM}])"
  @TOP_LABEL    = "(?:[#{@ALPHA}]|[#{@ALPHA}](?:[#{@ALPHA}]|-)*[#{@ALPHA}])"
  @HOSTNAME     = "(?:#{@DOMAIN_LABEL}\\.)*#{@TOP_LABEL}\\.?"
  @IP4          = "[#{@DIGIT}]{1,3}\\.[#{@DIGIT}]{1,3}\\.[#{@DIGIT}]{1,3}\\.[#{@DIGIT}]{1,3}"
  @HOST         = "(?<host>#{@HOSTNAME}|#{@IP4})"
  @PORT         = "(?<port>[#{@DIGIT}]+)"
  @HOSTPORT     = "#{@HOST}(?::#{@PORT})?"
  @SERVER       = "(?:(?:#{@USERINFO}@)?#{@HOSTPORT})?"
  @AUTHORITY    = "(?:#{@SERVER}|#{@REG_NAME})"
  
  @PCHAR         = "(?:[#{@UNRESERVED}:@&=\\+\\$,]|#{@ESCAPED})"
  @PARAM         = "#{@PCHAR}*"
  @SEGMENT       = "#{@PCHAR}*(?:;#{@PARAM})*"
  @REL_SEGMENT   = "(?:[#{@UNRESERVED};@&=\\+\\$,]|#{@ESCAPED})+"
  @PATH_SEGMENTS = "#{@SEGMENT}(?:/#{@SEGMENT})*" 
  @REL_PATH      = "(?<path>#{@REL_SEGMENT}(?:#{@ABS_PATH})?)"
  @ABS_PATH      = "(?<path>/#{@PATH_SEGMENTS})"
  @NET_PATH      = "//#{@AUTHORITY}(?:#{@ABS_PATH})?"
  
  @QUERY = "(?<query>#{@URIC}*)"
  
  @HIER_PART    = "(?:#{@NET_PATH}|#{@ABS_PATH})(?:\\?#{@QUERY})?"
  @OPAQUE_PART  = "(?<opaque>#{@URIC_NO_SLASH}#{@URIC}*)"
  
  @FRAGMENT = "(?<fragment>#{@URIC}*)"
  
  @RELATIVE_URI = "(?:#{@NET_PATH}|#{@ABS_PATH}|#{@REL_PATH})(?:\\?#{@QUERY})?(?:##{@FRAGMENT})?"
  @ABSOLUTE_URI = "#{@SCHEME}:(?:#{@HIER_PART}|#{@OPAQUE_PART})(?:##{@FRAGMENT})?"
).call exports

exports.compilePattern = (source) ->
  RegExp "^#{source}$".replace /// \(\? <[^>]+> ///g, '(?:'

exports.compileParser = (source) ->
  captures = []
  
  re = RegExp "^#{source}$".replace /// \(\? <([^>]+)> ///g, ($_, $1) ->
    captures.push $1
    "("
  
  split = (str) ->
    if match = @re.exec str
      uri = {}
      for name, i in @captures
        str = match[i + 1]
        uri[name] = str if str?
      uri
  
  {re, captures, split}

rel = exports.compileParser exports.RELATIVE_URI
abs = exports.compileParser exports.ABSOLUTE_URI

exports.split = (str) ->
  abs.split(str) ? rel.split(str)
