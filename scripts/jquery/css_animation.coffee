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

makeCSSTime = (time, def) ->
  if not time?
    def
  if typeof time is 'number' or /^\d+$/.test(time)
    "#{time}ms"
  else
    time

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
          noAnimation = {}
          for optionName, styleName of styleProperties
            noAnimation[styleName] = ''
          $(this).css noAnimation
          optall.old?.call this, event
  
  animation[styleProperties.name] = animationName
  noAnimation[styleProperties.name] = ''
  
  for optionName, styleName of styleProperties when optall[optionName]?
    animation[styleName] = "#{optall[optionName]}"
    noAnimation[styleName] = ''
  
  $(this).bind(eventNames.animationEnd, realCallback).css(animation)
