templates = {}

actions = 
  sendFile: ->
    textField = $('#messageInput')
    sendFile encodeURI textField.val()
    textField.val ''

users =
  bot:
    displayName: 'Orange Colander'
    screenName: 'orangecolander'
  me:
    displayName: 'Me'
    screenName: 'myownself'

$.get 'incoming/Content.html', (text) -> templates.message = text
$.get 'Status.html', (text) -> templates.status = text  
$.get 'FileTransferRequest.html', (text) -> templates.fileTransfer = text

$(document).on 'click', 'button[data-action]', (event) ->
  actionName = $(this).data('action')
  if actionName of actions
    actions[actionName].apply this, arguments
  else
    console.error "undefined action #{actionName}"

$ ->
  $('#messageInput').on 'keydown', (event) ->
    if event.which is 13 and not event.altKey
      event.preventDefault()
      sendMessage $(this).val()
      $(this).val ''
  
  $(messageView).on 'load', ->
    $ = jQuery = messageView.jQuery
    
    $(document).on 'click', 'a', (event) -> event.preventDefault()
    
    _ajax = jQuery.ajax
    jQuery.ajax = (url, options) ->
      [url, options] = [null, url] if typeof url is 'object'
      if /// https?:// ///.test url
        (options.data ?= {})._url = url ? options.url
        _ajax.call this, '/ajax', options
      else
        _ajax.call this, url, options

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

appendMessage = (text, options = {}) ->
  type = options.type ? 'message'
  user = options.user ? users.me
  
  classNames = [ type ]
  classNames.push 'mention' if containsWord text, user.screenName
  classNames.push options.status if type is 'status'
  classNames.push 'outgoing' if options.outgoing
  classNames.push 'incoming' if options.incoming
  
  data =
    time: formatTime()
    sender: user.displayName
    senderScreenName: user.screenName
    messageClasses: classNames.join(' ')
    message: markup text
  
  html = fillTemplate templates.message, data
  messageView.appendMessage html
  
sendMessage = (text) ->
  appendMessage text, outgoing: true, user: users.me
  
  $.post '/chat', message: text, ->
    $.get '/chat', (text) -> receiveMessage text

receiveMessage = (text) ->
  appendMessage text, incoming: true, user: users.bot

sendFile = (fileName, options = {}) ->
  user = options.user ? users.me
  
  html = fillTemplate templates.fileTransfer,
    sender: user.displayName
    senderScreenName: user.screenName
    fileIconPath: '/images/icons/fire.png'
    fileName: fileName
    
  messageView.appendMessage html
