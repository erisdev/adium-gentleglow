class $.model.Message extends $.model.BaseModel
  @property 'displayName', '.gg-messageSender'
  @property 'userName',    '.gg-messageSenderId'
  @property 'timestamp',   '.gg-messageTimestamp'
  @property 'body',        '.gg-messageBody'
  
  isAction: -> $(@rootElement).hasClass 'action'
  isHistory: -> $(@rootElement).hasClass 'history'
  isMention: -> $(@rootElement).hasClass 'mention'
  isMessage: -> $(@rootElement).hasClass 'message'
  
  getDate: ->
    # No, seriously. `Date(...)` properly parses an ISO string, but it returns
    # another string representation; `new Date(...)` returns a Date object and
    # can't parse ISO strings (at least in Chrome, where this style is tested)
    # but it can parse the string returned by `Date(...)`.
    # The JavaScript Date object: an exercise in _for god's sake, why_.
    new Date Date $(@rootElement).find('.gg-messageTimestamp').attr('datetime')

# TODO separate StatusMessage class with appropriate methods
$.model.StatusMessage = $.model.Message

TMPL =
  textShadow: '0px 0px 20px #{color}'

shouldAutoScroll = ->
  chatBuffer = $('#gg-chatBuffer')
  scrollTop = chatBuffer.scrollTop()
  scrollHeight = chatBuffer[0].scrollHeight
  innerHeight = chatBuffer.innerHeight()
  (scrollTop >= (scrollHeight - innerHeight * 1.2 ))

$(window).bind 'adium:message adium:status', (event) ->
  message = event.message.model()
  message.shouldScroll = shouldAutoScroll()
  
  if message.isMessage()
    hash = message.userName.toLowerCase().hash()
    color = "hsl(#{hash % 360}, 50%, 60%)"
    message.find('.gg-messageInfo').css {color, textShadow: "0 0 20px #{color}"}
  
  if message.isAction()
    message.find('.actionMessageBody').text (i, text) -> " #{text}"
  
  $(message.rootElement).hide().appendTo('#gg-chatBuffer').fadeIn()
  
  # scroll down if appropriate
  alignChat() if message.shouldScroll

$ ->
  initialize()
  
  scroller = $('#gg-chatQuickScroller').hide()
  scroller.bind 'click', (event) -> alignChat()
  
  previousShouldShow = false
  showOrHideScroller = ->
    shouldShow = not shouldAutoScroll()
    if shouldShow isnt previousShouldShow
      if shouldShow
        scroller.cssFadeIn()
      else
        scroller.cssFadeOut()
    previousShouldShow = shouldShow
  
  $('#gg-chatBuffer').bind 'scroll', showOrHideScroller
  $(window).bind 'resize', showOrHideScroller