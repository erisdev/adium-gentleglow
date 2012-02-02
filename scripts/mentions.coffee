MENTION_TEMPLATE = '''
  <li class="gg-mention" title="#{body.escapeEntities()}">
    <a href="##{id}">mentioned</a>
    by <span class="gg-user" title="#{userName}">#{displayName}</span>
    at <time class="gg-timestamp">#{timestamp}</time>
  </li>
'''

flash = (el) ->
  $(el).css
    webkitAnimationName: 'fx-flash'
    webkitAnimationDelay: '200ms'
    webkitAnimationDuration: '200ms'

$(window).bind 'adium:message', (event) ->
  message = event.message.model()
  console.log message
  if message.isMention()
    $('#mentions .ui-menuContent').append MENTION_TEMPLATE.template message
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

$('.mention').live 'webkitAnimationEnd', (event) ->
  $(this).css
    webkitAnimationName: ''
    webkitAnimationDelay: ''
    webkitAnimationDuration: ''
