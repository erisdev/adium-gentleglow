templates = {}

actions = 
  sendFile: ->
    textField = $('#messageInput')
    sendFile encodeURI textField.val()
    textField.val ''

user =
  displayName: 'Orange Colander'
  screenName: 'orangecolander'

$.get 'incoming/Content.html', (text) -> templates.message = text
$.get 'Status.html', (text) -> templates.status = text  
$.get 'FileTransferRequest.html', (text) -> templates.fileTransfer = text

$('button[data-action]').live 'click', (event) ->
  actionName = $(this).data('action')
  if actionName of actions
    actions[actionName].apply this, arguments
  else
    console.error "undefined action #{actionName}"

$ ->
  $('#messageInput').bind 'keydown', (event) ->
    if event.which is 13 and not event.altKey
      event.preventDefault()
      sendMessage $(this).val()
      $(this).val ''
  
  $(messageView).bind 'load', ->
    $ = jQuery = messageView.jQuery
    
    $('a').live 'click', (event) -> event.preventDefault()
    
    _ajax = jQuery.ajax
    jQuery.ajax = (url, options) ->
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

fillTemplate = (template, data) ->
  template.replace /%([A-Za-z]+)%/g, (m, key) -> data[key]

containsWord = (text, word) -> ///\b#{word}\b///.test text

sendMessage = (text, options = {}) ->
  type = options.type ? 'message'
  
  classNames = [ type ]
  classNames.push 'mention' if containsWord text, user.screenName
  classNames.push options.status if type is 'status'
  classNames.push if options.outgoing then 'outgoing' else 'incoming'
  
  data =
    time: formatTime()
    sender: user.displayName
    senderScreenName: user.screenName
    messageClasses: classNames.join(' ')
    message: markup text
  
  html = fillTemplate templates.message, data
  messageView.appendMessage html

sendFile = (fileName, options = {}) ->
  html = fillTemplate templates.fileTransfer,
    sender: user.displayName
    senderScreenName: user.screenName
    fileIconPath: '/images/fire.png'
    fileName: fileName
    
  messageView.appendMessage html
