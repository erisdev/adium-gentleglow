characterEscapes =
  "\n": 'n'
  "\t": 't'
  '\\': '\\'
  '"' : '"'

padDigits = (number, length, base = 10) ->
  string = number.toString(base)
  string = "0#{string}" while string.length < length
  string

escapeString = (string) ->
  string.replace /[\\"\n]/g, (ch) ->
    if escape = characterEscapes[ch]
      "\\#{escape}"
    else
      "\\u#{padDigits ch.charCodeAt(0), 4, 16}"

yield = (obj, fn) ->
  fn(obj)
  obj

class Console
  KEY_RETURN = 13
  KEY_LEFT   = 37
  KEY_UP     = 38
  KEY_RIGHT  = 39
  KEY_DOWN   = 40
  
  constructor: (root, buffer, input) ->
    @root   = $(root)
    @buffer = if buffer? then $(buffer) else $('.console-buffer', @root)
    @input  = if input?  then $(input)  else $('.console-input',  @root)
    
    @history = [ ]
    @history.limit = 100
    @history.index = -1
    
    @bufferLimit = 20
    
    @input.keydown (event) => @handleKey(event)
  
  handleKey: (event) ->
    if event.altKey
      switch event.which
        when KEY_UP   then @selectHistory +1; event.preventDefault()
        when KEY_DOWN then @selectHistory -1; event.preventDefault()
    else
      switch event.which
        when KEY_RETURN then @processInput(); event.preventDefault()
  
  processInput: ->
    try
      @dump CoffeeScript.eval @input.val(), bare: true
      @pushHistory()
      @clearInput()
    catch ex
      @error ex
      @input.select()
    
    @scrollToBottom()
    return
  
  clearInput: ->
    @input.val null
    return
  
  pushHistory: (command) ->
    command ?= @input.val()
    @history.unshift command
    @history.index = 0
    @history.pop() while @history.length > @history.limit
    return
  
  selectHistory: (offset) ->
    index = @history.index + offset
    console.log index
    if index >= @history.length
      undefined # TODO play donk sound or something
    else if index < 0
      @clearInput()
      @history.index = -1
    else
      @history.index = index
      command = @history[index]
      @input.val(command).select()
    return
  
  scrollToBottom: ->
    @root.scrollTo '100%'
    return
  
  cullBuffer: ->
    children = @buffer.children()
    overflow = children.length - @bufferLimit
    if overflow > 0
      children.slice(0, overflow).remove()
  
  # I'd love to use CSS transitions but they don't work when the display
  # style changes.
  show: ->
    @root.show arguments...
    @scrollToBottom
    return
  
  hide: ->
    @root.hide arguments...
    return
  
  log: (message, options) ->
    $('<div>')
    .addClass(options?.class ? 'console-message')
    .text("#{message}")
    .appendTo(@buffer)
    @cullBuffer()
    return
  
  info:  (message) -> @log message, class: 'console-info'
  warn:  (message) -> @log message, class: 'console-warning'
  error: (message) -> @log message, class: 'console-error'
  
  @valueToHtml: (object, options) ->
    type = typeof object
    converter = @valueConverters[type] ? @valueConverters['default']
    
    if options?.collapse and @valueIsCollapsible(object, type)
      firstLine = "#{object}".match(/^.+$/m)[0]
      stub = $('<pre>').addClass('debug-collapsed').text(firstLine)
      stub.click (event) -> stub.replaceWith(Console.valueToHtml(object))
    else
      converter object, type
  
  @valueIsCollapsible: (object, type) ->
    if type is 'object'
      if $.isArray(object)
        object.length > 0
      else
        object not instanceof Date
    else if type is 'function'
      true
    else
      false
  
  @valueConverters:
    default: (value, type) ->
      $('<pre>').addClass("debug-#{type}").text("#{value}")
    undefined: (value) ->
      $('<span>').addClass('debug-undefined').text('undefined')
    string: (string) ->
      $('<span>').addClass('debug-string').text(escapeString string)
    boolean: (flag) ->
      $('<span>').addClass('debug-boolean').text(flag ? 'true' : 'false')
    function: (fn) ->
      $('<pre>').addClass('debug-function').text("#{fn}")
    object: (object) ->
      if object is null
        $('<span>').addClass('debug-null').text('null')
      else if $.isArray object
        yield $('<ol>').addClass('debug-array'), (html) =>
          for value in object
            $('<li>')
            .addClass('debug-array-entry')
            .append(Console.valueToHtml(value, collapse: true))
            .appendTo(html)
        
      else if object instanceof Date
        $('<time>')
        .addClass('debug-date')
        .attr(datetime: object.toISOString())
        .text(object.toLocaleString())
      else
        html = $('<ul>').addClass('debug-object')
        for own key, value of object
          $('<li>')
          .addClass('debug-object-entry')
          .append(
            $('<div>')
            .addClass('debug-object-key')
            .text(key) )
          .append(
            $('<div>')
            .addClass('debug-object-value')
            .append(Console.valueToHtml(value, collapse: true)) )
          .appendTo(html)
        html
  
  dump: (object) ->
    try
      html = Console.valueToHtml object, collapse: true
      $('<div>')
      .addClass('console-dump')
      .append(html)
      .appendTo(@buffer)
    finally
      @cullBuffer()
      @scrollToBottom()

$ ->
  debugConsole = new Console '#debug-console'
  debugConsole.hide()
  
  $('#console-toggle').click (event) ->
    if $(this).is(':checked')
      debugConsole.show 'normal'
    else
      debugConsole.hide 'normal'

window.Console = Console
