MENTION_TEMPLATE = '''
  <li class="gg-mention">
    by <span class="gg-user" title=#{screenName}>#{displayName}</span>
    at <time class="gg-timestamp">#{timestamp}</span>
  </li>
'''

$(window).bind 'adium:message', (event) ->
  message = event.message
  if message.hasClass 'mention'
    html = MENTION_TEMPLATE.template
      screenName: message.find('.gg-messageSenderId').text()
      displayName: message.find('.gg-messageSender').text()
      timestamp: message.find('.gg-messageTimestamp').text()
    $('#mentions').append html