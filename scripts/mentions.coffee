resources = require 'resources'
UIMenu = require 'ui/menu'

messages = []

flash = (el) ->
  $(el).cssAnimate 'fx-flash', duration: 100, delay: 200, iterations: 2

exports.remember = (message) ->
  messages.push message
  exports.menu.addItem null, {message}, ->
    height = $('#gg-chatBuffer').height()
    el = $(message.rootElement)
    
    $('#gg-chatBuffer').stop().scrollTo el,
      duration: 700
      easing: 'swing'
      offset: { top: -height / 3 }
      onAfter: -> flash el

exports.menu = new UIMenu 'Mentions',
  itemTemplate: 'views/mention'
