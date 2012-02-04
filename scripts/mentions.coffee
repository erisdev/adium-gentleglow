MENTION_TEMPLATE = '''
  <li class="gg-mention" title="#{body.escapeEntities()}">
    <a href="##{id}">mentioned</a>
    by <span class="gg-user" title="#{userName}">#{displayName}</span>
    at <time class="gg-timestamp">#{timestamp}</time>
  </li>
'''

flash = (el) ->
  $(el).cssAnimate 'fx-flash', duration: 100, delay: 200, iterations: 2

$(window).bind 'adium:message', (event) ->
  message = event.message.model()
  console.log message
  if message.isMention()
    $('#mentions .ui-menuContent')
    .append(MENTION_TEMPLATE.template message)
    .stop().scrollTo '100%', 200, 'swing'
    
    flash message.rootElement

$('.gg-mention a').live 'click', (event) ->
  event.preventDefault()
  
  height = $('#chat').height()
  selector = $(this).attr 'href'
  
  $('#chat').stop().scrollTo selector,
    duration: 700
    easing: 'swing'
    offset: { top: -height / 3 }
    onAfter: -> flash selector
