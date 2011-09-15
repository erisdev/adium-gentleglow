# load custom jQuery plugins
require 'jquery/css_animation'
require 'jquery/model/message'

preview = require 'preview'
preview.register require('preview/danbooru')
preview.register require('preview/imgur')
preview.register require('preview/oembed')
preview.register require('preview/reddit')
preview.register require('preview/tumblr')
preview.register require('preview/twitter')
preview.register require('preview/embedly')

resources = require 'resources'
preferences = require 'preferences'
mentions = require 'mentions'
UIMenu = require 'ui/menu'
toolbar = require 'ui/toolbar'

shouldAutoScroll = ->
  chatBuffer = $('#gg-chatBuffer')
  scrollTop = chatBuffer.scrollTop()
  scrollHeight = chatBuffer[0].scrollHeight
  innerHeight = chatBuffer.innerHeight()
  (scrollTop >= (scrollHeight - innerHeight * 1.2 ))

flash = (el) ->
  $(el).cssAnimate 'fx-flash', duration: 100, delay: 200, iterations: 2

$(window).bind 'adium:file', (event) ->
  fileTransfer = event.file
  
  fileTransfer
  .css(position: 'fixed', left: '2em', bottom: '2em', right: '2em')
  .appendTo('body')
  .cssAnimate('fx-winkIn')
  
  fileTransfer.find('button').click (event) ->
    fileTransfer.cssAnimate 'fx-winkOut', -> fileTransfer.remove()

$(window).bind 'adium:message', (event) ->
  message = event.message.model()
  
  # colorise sender name
  hash = message.userName.toLowerCase().hash()
  color = "hsl(#{hash % 360}, 50%, 60%)"
  message.find('.gg-messageInfo').css {color, textShadow: "0 0 20px #{color}"}
  
  # shorten link text for bare links
  message.find('a')
  .filter( -> $(this).text() is $(this).attr('href') )
  .text( (i, text) -> text.replace /// \w+ :// ([^/]+ (?: / .{1,10} )? ) .* ///, '$1\u2026' )
  .addClass('shortened')

  # collect and flash mentions
  if message.isMention()
    mentions.remember message
    flash message.rootElement
    
    toolbar.getButton('mentions').tap (button) ->
      button.icon = 'mailopened'
      button.badge = +button.badge + 1
  
  # dirty hax. action message body and sender name get crammed together for
  # some reason when jQuery parses them.
  if message.isAction()
    message.find('.actionMessageBody').text (i, text) -> " #{text}"
  
  # scrape links for previewable stuff in new messages
  unless message.isHistory() or not preferences.get('enablePreviews')
    message.find('a').each -> preview.loadPreviews event.message, this

$(window).bind 'adium:message adium:status', (event) ->
  message = event.message.model()
  message.shouldScroll = shouldAutoScroll()
  
  # append message to chat buffer with fadein
  $(message.rootElement).hide().appendTo('#gg-chatBuffer').cssFadeIn()
  
  # scroll down if appropriate
  alignChat() if message.shouldScroll

# preferences
$(window).bind 'gg:preferences', (event) ->
  if event.key is 'enableEffects'
    $.fx.off = not event.newValue

$.fx.off = not preferences.get 'enableEffects'

$ ->
  # create console instance
  Console = require 'console'
  Console.instance = new Console '#debug-console'
  Console.instance.hide()
  
  toolbar.addButton 'Mentions', icon: 'mailclosed', (event) ->
    this.icon = 'mailclosed'
    this.badge = ''
    mentions.menu.toggle event.clientX, event.clientY
  
  toolbar.addButton 'Preferences', icon: 'preferences', ->
    preferences.panel.toggle()
  
  toolbar.addButton 'Debug Console', icon: 'monitor', ->
    if Console.instance.root.is(':visible')
      Console.instance.hide 'normal'
    else
      Console.instance.show 'normal'
  
  variantsMenu = new UIMenu 'Variants', (menu) ->
    for own variant of require('message_style').variants then do (variant) =>
      menu.item variant, -> $('#mainStyle').text """
        @import url("Variants/#{variant}.css");
      """
  toolbar.addButton 'Variant', icon: 'lightbulb', (event) ->
    variantsMenu.toggle(event.clientX, event.clientY)
  
  # set up the quick scroll to bottom button
  scroller = $('#gg-chatQuickScroller').hide()
  scroller.bind 'click', (event) -> alignChat()
  
  previousShouldShow = false
  showOrHideScroller = ->
    shouldShow = not shouldAutoScroll()
    if shouldShow isnt previousShouldShow
      if shouldShow
        scroller.cssFadeIn()
      else
        scroller.cssFadeOut()
    previousShouldShow = shouldShow
  
  $('#gg-chatBuffer').bind 'scroll', showOrHideScroller
  $(window).bind 'resize', showOrHideScroller
  
  # signal that we're ready to start receiving message events
  initialize()
