flash = (el) ->
  $(el).cssAnimate 'fx-flash', duration: 100, delay: 200, iterations: 2

$(window).bind 'adium:message', (event) ->
  message = event.message.model()
  if message.isMention()
    $('#mentions .ui-menuContent')
    .append(resources.get('views/mention')({message}))
    .stop().scrollTo '100%', 200, 'swing'
    
    flash message.rootElement

$('.gg-mention a').live 'click', (event) ->
  event.preventDefault()
  
  height = $('#gg-chatBuffer').height()
  selector = $(this).attr 'href'
  
  $('#gg-chatBuffer').stop().scrollTo selector,
    duration: 700
    easing: 'swing'
    offset: { top: -height / 3 }
    onAfter: -> flash selector
