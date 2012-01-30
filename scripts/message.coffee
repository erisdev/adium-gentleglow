TMPL =
  textShadow: '0px 0px 20px #{color}'

$(window).bind 'adium:message', (event) ->
  message = event.message
  shouldScroll = false
  
  do ->
    # determine whether scrolling is appropriate or not
    chatBuffer = $('#chat')
    scrollTop = chatBuffer.scrollTop()
    scrollHeight = chatBuffer[0].scrollHeight
    innerHeight = chatBuffer.innerHeight()
    
    shouldScroll = (scrollTop >= (scrollHeight - innerHeight * 1.2 ))
    
    message.data {shouldScroll}
  
  if message.hasClass 'message'
    message.find('.gg-messageInfo')
    .colorHash('.gg-messageSenderId',
      saturation: 0.5,
      luminance:  0.6,
      ignoreCase: true )
    .css('text-shadow', (i, textShadow) ->
      TMPL.textShadow.template color: $(this).css('color') )
  
  if message.hasClass 'action'
    message.find('.actionMessageUserName').addClass('gg-messageSender')
    message.find('.actionMessageBody').text (i, text) -> " #{text}"
  
  message.hide().appendTo('#chat').fadeIn()
  
  # scroll down if appropriate
  alignChat() if shouldScroll

$ -> initialize()
