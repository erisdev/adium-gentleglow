MENTION_TEMPLATE = '''
  <li class="gg-mention" title="#{text}">
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
      text: message.find('.gg-messageContent').text().escapeEntities()
      screenName: message.find('.gg-messageSenderId').text()
      displayName: message.find('.gg-messageSender').text()
      timestamp: message.find('.gg-messageTimestamp').text()
    $('#mentions .ui-menuContent').append html

$('.gg-mention a').live 'click', (event) ->
  event.preventDefault()
  
  height = $('#chat').height()
  selector = $(this).attr 'href'
  
  $('#chat').stop().scrollTo selector,
    duration: 700
    easing: 'swing'
    offset: { top: -height / 3 }
