# load custom jQuery plugins
require 'jquery/css_animation'
require 'jquery/model/menu'
require 'jquery/model/message'

preview = require 'preview'
preview.register require('preview/imgur')
preview.register require('preview/oembed')
preview.register require('preview/reddit')
preview.register require('preview/tumblr')
preview.register require('preview/twitter')
preview.register require('preview/embedly')

resources = require 'resources'
preferences = require 'preferences'

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
    $('#mentions .ui-menuContent')
    .append(resources.get('views/mention')({message}))
    .stop().scrollTo '100%', 200, 'swing'
    
    flash message.rootElement
  
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

# mentions
$('.gg-mention a').live 'click', (event) ->
  event.preventDefault()
  
  height = $('#gg-chatBuffer').height()
  selector = $(this).attr 'href'
  
  $('#gg-chatBuffer').stop().scrollTo selector,
    duration: 700
    easing: 'swing'
    offset: { top: -height / 3 }
    onAfter: -> flash selector

# menus
$('.ui-menu .ui-menuHeader').live 'click', (event) ->
  $(this).closest('.ui-menu').model().togglePinned()

$ ->
  currentVariantPattern = /// url\( "? variants/ ([^\s"]+) \.css "? \) ///i
  
  # add a menu item to open the preferences window
  $('#main-menu').model().addLink 'preferences', -> preferences.panel.toggle()
  
  # add a menu item to change variants
  $('#main-menu').model().addSelect 'variant',
    values: require('message_style').variants.getOwnKeys(),
    defaultValue: $('#mainStyle').text().match(currentVariantPattern)?[1]
  , ->
    $('#mainStyle').text("""@import url("Variants/#{$(this).val()}.css");""")
    $('#main-menu').model().unpin()
    scrollToBottom()
  
  # create console instance
  Console = require 'console'
  Console.instance = new Console '#debug-console'
  Console.instance.hide()
  
  # add debug console menu item
  $('#main-menu').model().addCheckbox 'debug console', (event) ->
    if $(this).is(':checked')
      Console.instance.show 'normal'
    else
      Console.instance.hide 'normal'
  
  
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
