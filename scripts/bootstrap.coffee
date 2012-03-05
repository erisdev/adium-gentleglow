ready = false
messageQueue = []

triggerMessageEvent = (html) ->
  html = $(html)
  className = html.data('className')
  
  ev = switch className
    when 'FileTransfer'  then jQuery.Event 'adium:file', file: html
    when 'StatusMessage' then jQuery.Event 'adium:status', message: html
    when 'Message'       then jQuery.Event 'adium:message', message: html
  $(window).trigger ev

window.initialize = ->
  ready = true
  triggerMessageEvent message for message in messageQueue

window.appendMessage = (message) ->
  if ready
    triggerMessageEvent message
  else
    messageQueue.push message

# these all do the same thing for this style
window.appendNextMessage = window.appendMessage
window.appendMessageNoScroll = window.appendMessage
window.appendNextMessageNoScroll = window.appendNextMessage
# window.replaceLastMessage is never called with a custom Template.html

# the message style handles scrolling
window.checkIfScrollToBottomIsNeeded = ->
window.scrollToBottomIfNeeded = ->

window.alignChat = ->
  $('#gg-chatBuffer').stop().scrollTo '100%', 700, easing: 'swing'

window.setStylesheet = (id, src) ->
  style = $("##{id}")
  
  if style.length is 0
    style = $('<style>').attr
      id: id
      type: 'text/css'
      media: 'screen'
  
  style.text """@import url("#{src}");"""
