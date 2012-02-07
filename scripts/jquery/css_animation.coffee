styleProperties =
  name: 'webkitAnimationName'
  delay: 'webkitAnimationDelay'
  direction: 'webkitAnimationDirection'
  duration: 'webkitAnimationDuration'
  easing: 'webkitAnimationTimingFunction'
  fillStyle: 'webkitAnimationFillStyle'
  iterations: 'webkitAnimationIterationCount'

eventNames =
  animationEnd: 'webkitAnimationEnd'

jQuery.cssAnimations =
  fadeIn: 'fx-fadeIn'
  fadeOut: 'fx-fadeOut'

makeCSSTime = (time, def) ->
  if not time?
    def
  if typeof time is 'number' or /^\d+$/.test(time)
    "#{time}ms"
  else
    time

jQuery.fn.cssFadeOut = (speed, easing, callback) ->
  {fadeIn, fadeOut} = jQuery.cssAnimations
  
  hideCallback = (event) ->
    if event.originalEvent.animationName is fadeOut
      $(this).css(display: 'none').unbind(event.type, hideCallback)
  
  $(this)
  .cssStop(fadeIn)
  .cssAnimate(fadeOut, speed, easing, callback)
  .bind(eventNames.animationEnd, hideCallback)

jQuery.fn.cssFadeIn = (speed, easing, callback) ->
  {fadeIn, fadeOut} = jQuery.cssAnimations
  $(this)
  .css(display: '')
  .cssStop(fadeOut)
  .cssAnimate(fadeIn, speed, easing, callback)

jQuery.fn.cssStop = (animationName) ->
  # TODO actually do this once multiple concurrent animations are supported
  this

jQuery.fn.cssAnimate = (animationName, speed, easing, callback) ->
  optall = jQuery.speed speed, easing, callback
  optall.duration = makeCSSTime optall.duration
  optall.delay    = makeCSSTime optall.delay, 0
  
  animation = {}
  noAnimation = {}
  
  realCallback = (event) ->
    $(this).unbind event.type, realCallback
    if event.originalEvent.animationName is animationName
      switch event.type
        when eventNames.animationEnd
          $(this).css noAnimation
          optall.old.call this, event if typeof optall.old is 'function'
  
  animation[styleProperties.name] = animationName
  noAnimation[styleProperties.name] = ''
  
  for optionName, styleName of styleProperties when optall[optionName]?
    animation[styleName] = "#{optall[optionName]}"
    noAnimation[styleName] = ''
  
  $(this).bind(eventNames.animationEnd, realCallback).css(animation)
