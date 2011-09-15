TMPL =
  textShadow: '0px 0px 20px #{color}'

template = (string, params) ->
  pattern = /// \#\{ \s* ([a-z0-9_]+) \s* \} | \$ (\d+) ///ig
  string.replace pattern, (m, key, index) ->
    switch m.charAt 0
      when '#' then params[key]
      when '$' then params[parseInt index]
      else          'undefined'
  
appendMessage = (html) ->
  fragment = $ html
  
  if fragment.hasClass 'message'
    $('.meta', fragment)
    .colorHash('.sender_id',
      saturation: 0.5,
      luminance:  0.6,
      ignoreCase: true )
    .css('text-shadow', (i, textShadow) ->
      template TMPL.textShadow, color: $(this).css('color') )
  
  if fragment.hasClass 'action'
    # reformat action text IRC style
    
    sender  = $('.meta .sender', fragment).text()
    content = $ '.content', fragment
    
    content.html (i, html) ->
      # strips asterisks
      # we do this to the raw html to preserve formatting--gross, I know.
      html
      .replace(///^   ( < [^>]+ > )? \* ///, '$1')
      .replace(/// \* ( < [^>]+ > )?   $///, '$1')
    
    # prepend the sender in a span of its own
    $('<span>')
    .addClass('sender')
    .text(sender + ' ')
    .prependTo(content)
  
  $('a', fragment)
  .each( (i) -> Preview.loadPreviews fragment, this )
  .filter( (i) -> $(@).text() is $(@).attr('href') )
  .text( (i, text) -> text.replace /// \w+ :// ([^/]+) (?: /.* )? ///, '$1\u2026' )
  .addClass('shortened')
  
  $('button', fragment).button()
  
  fragment.hide().appendTo('#chat').fadeIn()

replaceLastMessage = (html) ->
  $('#chat > section:last').remove()
  appendMessage html

checkIfScrollToBottomIsNeeded = ->
  # TODO write a version of this that actually works
  checkIfScrollToBottomIsNeeded.isNeeded = true

checkIfScrollToBottomIsNeeded.isNeeded = true

scrollToBottom = (immediate) ->
  $('#chat').stop()
  $('#chat').scrollTo '100%', 700, easing: 'easeOutBounce'

scrollToBottomIfNeeded = ->
  scrollToBottom() if checkIfScrollToBottomIsNeeded.isNeeded

setStylesheet = (id, url) ->
  style = $ "#stylesheet-#{id}"
  
  if style.length is 0
    style = $('<style>')
    .attr('id',    id)
    .attr('type',  'text/css')
    .attr('media', 'screen')
    
  style.text "@import url(#{url})"

$ -> $.scrollTo '100%'

window.appendMessage = appendMessage
window.appendNextMessage = appendMessage
window.replaceLastMessage = replaceLastMessage
window.checkIfScrollToBottomIsNeeded = checkIfScrollToBottomIsNeeded
window.scrollToBottom = scrollToBottom
window.scrollToBottomIfNeeded = scrollToBottomIfNeeded
window.setStylesheet = setStylesheet
