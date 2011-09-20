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
  constructor: (root, buffer, input) ->
    @root   = $(root)
    @buffer = if buffer? then $(buffer) else $('.console-buffer', @root)
    @input  = if input?  then $(input)  else $('.console-input',  @root)
    
    @input.keypress (event) => @processInput() if event.charCode is 13
  
  processInput: ->
    try
      @dump CoffeeScript.eval @input.val(), bare: true
      @clearInput()
    catch ex
      @error ex
    
    @scrollToBottom()
    return
  
  clearInput: ->
    @input.val null
    return
  
  scrollToBottom: ->
    @root.scrollTo '100%'
    return
  
  log: (message, options) ->
    options = $.merge
      class: 'console-message'
      options
    
    $('<div>')
    .addClass(options.class)
    .text("#{message}")
    .appendTo(@buffer)
    return
  
  info:  (message) -> @log message, class: 'console-info'
  warn:  (message) -> @log message, class: 'console-warning'
  error: (message) -> @log message, class: 'console-error'
  
  @valueToHtml: (object) ->
    type = typeof object
    converter = @valueConverters[type] ? @valueConverters['default']
    converter object, type
  
  @valueConverters:
    default: (value, type) ->
      $('<span>').addClass("debug-#{type}").text("#{value}")
    undefined: ->
      $('<span>').addClass('debug-undefined').text('undefined')
    string: (string) ->
      $('<span>').addClass('debug-string').text(escapeString string)
    boolean: (flag) ->
      $('<span>').addClass('debug-boolean').text(flag ? 'true' : 'false')
    object: (object) ->
      if object is null
        $('<span>').addClass('debug-null').text('null')
      else if $.isArray object
        yield $('<ol>').addClass('debug-array'), (html) =>
          for value in object
            $('<li>')
            .addClass('debug-array-entry')
            .append(Console.valueToHtml value)
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
            .append(Console.valueToHtml(value)) )
          .appendTo(html)
        html
  
  dump: (object) ->
    try
      @buffer.append '<hr>'
      @buffer.append Console.valueToHtml object
    finally
      @scrollToBottom()

debugConsole = null
$ ->
  debugConsole = new Console '#debug-console'

window.Console = Console
