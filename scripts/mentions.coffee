MENTION_TEMPLATE = '''
  <li class="gg-mention">
    <a href="##{uuid}">mentioned</a>
    by <span class="gg-user" title=#{screenName}>#{displayName}</span>
    at <time class="gg-timestamp">#{timestamp}</time>
  </li>
'''

$(window).bind 'adium:message', (event) ->
  message = event.message
  if message.hasClass 'mention'
    unless uuid = message.attr('id')
      uuid = Math.uuid()
      message.attr id: uuid
      uuid
    
    html = MENTION_TEMPLATE.template
      uuid: uuid
      screenName: message.find('.gg-messageSenderId').text()
      displayName: message.find('.gg-messageSender').text()
      timestamp: message.find('.gg-messageTimestamp').text()
    $('#mentions .ui-menuContent').append html