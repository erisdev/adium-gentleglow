templates = {}

user =
  displayName: 'Orange Colander'
  screenName: 'orangecolander'

$ ->
  $.get 'incoming/Content.html', (text) -> templates.message = text
  $.get 'Status.html', (text) -> templates.status = text
  
  $('#messageInput').bind 'keydown', (event) ->
    if event.which is 13 and not event.altKey
      event.preventDefault()
      sendMessage $(this).val()
      $(this).val ''
  
  $(messageView).bind 'load', ->
    $('a').live 'click', (event) -> event.preventDefault()
    
    _ajax = messageView.jQuery.ajax
    messageView.jQuery.ajax = (url, options) ->
      options.data ?= {}
      options.data._url = url
      _ajax.call this, '/ajax', options

formatTime = (date = new Date) ->
  [ date.getHours(), date.getMinutes() ].join(':')

uriPattern = /[^:\/?\#]+:(?:\/\/(?:(?:[^:@\/]*(?::[^:@\/]*)?)?@)?[^:\/?\#]*(?::\d*)?)?(?:[^?\#]*)*(?:\?[^\#]*)?(?:\#.*)?/g
markup = (text) ->
  $('<div>').text(text).html() # escape HTML characters
  .replace(/\n/g, '<br>') # convert line breaks
  .replace(uriPattern, (uri) -> """<a href="#{uri}">#{uri}</a>""") # convert URIs to links

sendMessage = (text, options = {}) ->
  type = options.type ? 'message'
  
  classNames = [ type ]
  classNames.push options.status if type is 'status'
  classNames.push if options.outgoing then 'outgoing' else 'incoming'
  
  data =
    time: formatTime()
    sender: user.displayName
    senderScreenName: user.screenName
    messageClasses: classNames.join(' ')
    message: markup text
  
  html = templates.message.replace /%([A-Za-z]+)%/g, (m, key) -> data[key]
  
  messageView.appendNextMessage html