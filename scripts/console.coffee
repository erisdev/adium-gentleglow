characterEscapes =
  "\n": 'n'
  "\t": 't'
  '\\': '\\'
  '"' : '"'

escapeString = (string) ->
  string.replace /[\\"\n]/g, (ch) ->
    if escape = characterEscapes[ch]
      "\\#{escape}"
    else
      "\\u#{ch.charCodeAt(0).toPaddedString(4, 16)}"

class Editor
  KEYS =
    codesByName: { }
    namesByCode: { }
    namesByAlias: { }
  
  defineKey = (code, name, aliases...) ->
    for alias in [name, aliases...]
      KEYS.codesByName[alias] = code
      KEYS.namesByAlias[alias] = name
    
    KEYS.namesByCode[code] = name
  
  for letter in 'abcdefghijklmnopqrstuvwxyz01234567890'.split('')
    defineKey letter, letter
  
  defineKey   9, 'tab',    "\t"
  defineKey  13, 'return', "\n"
  defineKey  37, 'left'
  defineKey  38, 'up'
  defineKey  39, 'right'
  defineKey  40, 'down'
  
  keysymFromEvent = (event) ->
    mod = [
      '^' if event.ctrlKey
      '@' if event.altKey
      '$' if event.shiftKey ].sort().join('')
    name = KEYS.namesByCode[event.which]
    "#{mod}#{name}"
  
  normalizeKeysym = (sym) ->
    m = sym.match ///^ ([\^@\$]*) ([a-z][a-z0-9\-]*) $///i
    name = KEYS.namesByAlias[m[2]]
    mod = m[1].split('').sort().join('')
    "#{mod}#{name}"
  
  constructor: (input) ->
    @input = $(input)
    
    @bindings = { }
    
    @input.keydown (event) => @handleKey event
    @input.keyup (event) => @fitContent()
    @input.css resize: 'none'
    @shrink()
  
  bindKey: (sym, options, fn) ->
    [options, fn] = [{ }, options] if options and not fn
    sym = normalizeKeysym sym
    fn = @[fn] if typeof fn is 'string'
    @bindings[sym] =
      preventDefault: options?.preventDefault ? true
      fn: fn
  
  handleKey: (event) ->
    sym = keysymFromEvent event
    if binding = @bindings[sym]
      binding.fn.call this, event
      event.preventDefault() if binding.preventDefault
  
  insertText: (toInsert, select = false) ->
    {begin, end} = @getSelection false
    
    oldText = @input.val()
    newText = oldText[0...begin] + toInsert + oldText[end...]
    
    @input.val newText
    
    if select
      end = begin + toInsert.length
    else
      begin = end = begin + toInsert.length
    
    @setSelection {begin, end}
  
  indent: (levels = 1) ->
    input = @input[0]
    begin = input.selectionStart
    end = input.selectionEnd
    
    line = @getLineAtPosition()
    oldText = @input.val()
    newText = oldText[0...line.begin]
    
    tab = '  '
    
    if levels >= 0
      newText += tab for i in [0...levels]
      newText += line.text
    else
      newText += line.text.replace ///^ [ ]{2} {0, #{Math.abs levels} } ///, ''
    
    newText += oldText[line.end...]
    
    @input.val newText
    input.setSelectionRange(
      Math.max(line.begin, begin + levels * tab.length)
      Math.max(line.begin, end   + levels * tab.length) )
    
    newText
  
  insertNewLineAndIndent: ->
    @insertText "\n"
    # TODO indent to match previous line
  
  getLineAtPosition: (index) ->
    input = @input[0]
    
    index ?= input.selectionStart
    text = @input.val()
    
    begin = text.lastIndexOf '\n', index - 1
    end = text.indexOf '\n', index
    
    if begin < 0 then begin  = 0 \
                 else begin += 1
    if end   < 0 then end    = text.length
    
    { begin, end, text: text[begin...end] }
  
  getSelection: (getText = true) ->
    input = @input[0]
    begin = input.selectionStart
    end = input.selectionEnd
    { begin, end, text: @input.val()[begin...end] if getText }
  
  setSelection: (selection) ->
    @input[0].setSelectionRange selection.begin, selection.end
  
  clear: ->
    @input.val null
    @shrink()
    return
  
  fitContent: ->
    input = @input[0]
    
    outerHeight = input.clientHeight
    innerHeight = input.scrollHeight
    
    adjustedHeight = Math.max outerHeight, innerHeight
    adjustedHeight = Math.min adjustedHeight, @input.parent()[0].clientHeight / 2
    
    if adjustedHeight != input.clientHeight
      @input.css height: adjustedHeight
    
    return
  
  shrink: ->
    @input.css height: '1.5em'
    return

class Console
  COFFEESCRIPT_URI = 'https://raw.github.com/jashkenas/coffee-script/1.1.3/extras/coffee-script.js'
  
  @instance =
    dump:  -> console?.log   arguments...
    log:   -> console?.log   arguments...
    info:  -> console?.info  arguments...
    warn:  -> console?.warn  arguments...
    error: -> console?.error arguments...
  
  @dump:  -> @instance.dump  arguments...
  @log:   -> @instance.log   arguments...
  @info:  -> @instance.info  arguments...
  @warn:  -> @instance.warn  arguments...
  @error: -> @instance.error arguments...
  
  constructor: (root, buffer, input) ->
    @root   = $(root)
    @buffer = if buffer? then $(buffer) else $('.ui-consoleBuffer', @root)
    @input  = if input?  then $(input)  else $('.ui-consoleInput',  @root)
    
    @editor = new Editor @input
    
    @editor.bindKey '@up',     => @selectHistory +1
    @editor.bindKey '@down',   => @selectHistory -1
    
    @editor.bindKey 'tab',     -> @indent()
    @editor.bindKey '$tab',    -> @indent -1
    
    @editor.bindKey "@return", -> @insertNewLineAndIndent()
    @editor.bindKey "return",  => @processInput()
    
    @history = [ ]
    @history.limit = 100
    @history.index = -1
    
    @bufferLimit = 20
  
  processInput: ->
    if CoffeeScript?
      try
        @dump CoffeeScript.eval @input.val(), bare: true
        @pushHistory()
        @editor.clear()
      catch ex
        @error ex
        @input.select()
      
      @scrollToBottom()
    else
      $.getScript COFFEESCRIPT_URI, => this.processInput()
    return
  
  pushHistory: (command) ->
    command ?= @input.val()
    @history.unshift command
    @history.index = -1
    @history.pop() while @history.length > @history.limit
    return
  
  selectHistory: (offset) ->
    index = @history.index + offset
    if index >= @history.length
      undefined # TODO play donk sound or something
    else if index < 0
      @editor.clear()
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
    .addClass(options?.class ? 'ui-consoleMessage')
    .text("#{message}")
    .appendTo(@buffer)
    @cullBuffer()
    return
  
  info:  (message) -> @log message, class: 'ui-consoleInfo'
  warn:  (message) -> @log message, class: 'ui-consoleWarning'
  error: (message) -> @log message, class: 'ui-consoleError'
  
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
        $('<ol>').addClass('debug-array').tap (html) =>
          for value in object
            $('<li>')
            .addClass('debug-arrayEntry')
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
          .addClass('debug-objectEntry')
          .append(
            $('<div>')
            .addClass('debug-objectKey')
            .text(key) )
          .append(
            $('<div>')
            .addClass('debug-objectValue')
            .append(Console.valueToHtml(value, collapse: true)) )
          .appendTo(html)
        html
  
  dump: (object) ->
    try
      html = Console.valueToHtml object, collapse: true
      $('<div>')
      .addClass('ui-consoleDump')
      .append(html)
      .appendTo(@buffer)
    finally
      @cullBuffer()
      @scrollToBottom()

$ ->
  Console.instance = new Console '#debug-console'
  Console.instance.hide()
  
  Menu.mainMenu.addCheckbox 'debug console', (event) ->
    if $(this).is(':checked')
      Console.instance.show 'normal'
    else
      Console.instance.hide 'normal'

window.Console = Console
