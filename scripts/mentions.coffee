resources = require 'resources'
UIPanel = require 'ui/panel'

messages = []

exports.remember = (message) ->
  messages.push message

exports.panel = new UIPanel 'views/mentions',
  title: 'Mentions'
  id: 'gg-mentionsPanel'
  parameters: {messages}
