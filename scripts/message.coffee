class $.model.Message extends $.model.BaseModel
  @property 'displayName', '.gg-messageSender'
  @property 'userName',    '.gg-messageSenderId'
  @property 'timestamp',   '.gg-messageTimestamp'
  @property 'body',        '.gg-messageBody'
  
  isAction: -> $(@rootElement).hasClass 'action'
  isHistory: -> $(@rootElement).hasClass 'history'
  isMention: -> $(@rootElement).hasClass 'mention'
  isMessage: -> $(@rootElement).hasClass 'message'

# TODO separate StatusMessage class with appropriate methods
$.model.StatusMessage = $.model.Message

TMPL =
  textShadow: '0px 0px 20px #{color}'

$(window).bind 'adium:message adium:status', (event) ->
  message = event.message.model()
  shouldScroll = false
  
  do ->
    # determine whether scrolling is appropriate or not
    chatBuffer = $('#chat')
    scrollTop = chatBuffer.scrollTop()
    scrollHeight = chatBuffer[0].scrollHeight
    innerHeight = chatBuffer.innerHeight()
    
    message.shouldScroll = (scrollTop >= (scrollHeight - innerHeight * 1.2 ))
  
  if message.isMessage()
    hash = message.userName.toLowerCase().hash()
    color = "hsl(#{hash % 360}, 50%, 60%)"
    message.find('.gg-messageInfo').css {color, textShadow: "0 0 20px #{color}"}
  
  if message.isAction()
    message.find('.actionMessageBody').text (i, text) -> " #{text}"
  
  $(message.rootElement).hide().appendTo('#chat').fadeIn()
  
  # scroll down if appropriate
  alignChat() if message.shouldScroll

$ -> initialize()
