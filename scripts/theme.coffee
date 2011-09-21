TMPL =
  textShadow: '0px 0px 20px #{color}'

template = (string, params) ->
  pattern = /// \#\{ \s* ([a-z0-9_]+) \s* \} | \$ (\d+) ///ig
  string.replace pattern, (m, key, index) ->
    switch m.charAt 0
      when '#' then params[key]
      when '$' then params[parseInt index]
      else          'undefined'
  
appendMessage = (html, scroll = true) ->
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
    $('.actionMessageUserName', fragment).addClass('sender')
    $('.actionMessageBody', fragment).text (i, text) -> " #{text}"
  
  unless fragment.hasClass 'history'
    $('a', fragment)
    .each( (i) -> Preview.loadPreviews fragment, this )
    .filter( (i) -> $(@).text() is $(@).attr('href') )
    .text( (i, text) -> text.replace /// \w+ :// ([^/]+) (?: /.* )? ///, '$1\u2026' )
    .addClass('shortened')
  
  $('button', fragment).button()
  
  fragment.hide().appendTo('#chat').fadeIn()
  scrollToBottom() if scroll

replaceLastMessage = (html) ->
  $('#chat > section:last').remove()
  appendMessage html

scrollToBottom = ->
  $('#chat').stop()
  $('#chat').scrollTo '100%', 700, easing: 'easeOutBounce'

alignChat = (shouldScroll) ->
  scrollToBottom() if shouldScroll

setStylesheet = (id, url) ->
  style = $ "#stylesheet-#{id}"
  
  if style.length is 0
    style = $('<style>')
    .attr('id',    id)
    .attr('type',  'text/css')
    .attr('media', 'screen')
    
  style.text "@import url(#{url})"

$ -> $.scrollTo '100%'

window.appendMessage = (html) -> appendMessage html, true
window.appendMessageNoScroll = (html) -> appendMessage html, false

window.appendNextMessage = window.appendMessage
window.appendNextMessageNoScroll = window.appendMessageNoScroll
window.replaceLastMessage = replaceLastMessage
window.scrollToBottom = scrollToBottom
window.alignChat = alignChat
window.setStylesheet = setStylesheet
