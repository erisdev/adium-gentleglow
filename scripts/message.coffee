TMPL =
  textShadow: '0px 0px 20px #{color}'

$(window).bind 'adium:message', (event) ->
  message = event.message
  
  if message.hasClass 'message'
    message.find('.meta')
    .colorHash('.sender_id',
      saturation: 0.5,
      luminance:  0.6,
      ignoreCase: true )
    .css('text-shadow', (i, textShadow) ->
      TMPL.textShadow.template color: $(this).css('color') )
  
  if message.hasClass 'action'
    message.find('.actionMessageUserName').addClass('sender')
    message.find('.actionMessageBody').text (i, text) -> " #{text}"
  
  message.hide().appendTo('#chat').fadeIn()

$ -> initialize()
