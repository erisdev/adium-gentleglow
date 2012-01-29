ready = false
messageQueue = []

triggerMessageEvent = (html) ->
  $(window).trigger jQuery.Event('adium:message', message: $(html))

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
  $('#chat').stop().scrollTo '100%', 700, easing: 'easeOutBounce'

window.setStylesheet = (id, src) ->
  style = $("##{id}")
  
  if style.length is 0
    style = $('<style>').attr
      id: id
      type: 'text/css'
      media: 'screen'
  
  style.text """@import url("#{src}");"""
