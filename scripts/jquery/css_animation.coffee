jQuery.styleProperties =
  name: 'webkitAnimationName'
  delay: 'webkitAnimationDelay'
  direction: 'webkitAnimationDirection'
  duration: 'webkitAnimationDuration'
  easing: 'webkitAnimationTimingFunction'
  fillStyle: 'webkitAnimationFillStyle'
  iterations: 'webkitAnimationIterationCount'

jQuery.eventNames =
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

compileAnimations = (animations) ->
  {}.tap (css) ->
    for own propertyName, styleName of jQuery.styleProperties
      css[styleName] = (
        for own name, animation of animations
          value = animation[propertyName]
          if propertyName == 'delay' or propertyName is 'duration'
            makeCSSTime value, 0
          else
            value ? 'initial'
      ).join ', '

jQuery.event.props.push 'animationName'

jQuery.fn.cssFadeOut = (speed, easing, callback) ->
  {fadeIn, fadeOut} = jQuery.cssAnimations
  {animationEnd} = jQuery.eventNames
  
  hideCallback = (event) ->
    if event.animationName is fadeOut
      $(this)
      .css(display: 'none')
      .unbind(event.type, hideCallback)
  
  $(this)
  .cssStop(fadeIn)
  .cssAnimate(fadeOut, speed, easing, callback)
  .bind(animationEnd, hideCallback)

jQuery.fn.cssFadeIn = (speed, easing, callback) ->
  {fadeIn, fadeOut} = jQuery.cssAnimations
  $(this)
  .css(display: '')
  .cssStop(fadeOut)
  .cssAnimate(fadeIn, speed, easing, callback)

jQuery.fn.cssStop = (animationName) ->
  {animationEnd} = jQuery.eventNames
  $(this).each (i, el) ->
    el = $(el)
    if cssAnimations = el.data('cssAnimations')
      animation = cssAnimations[animationName]
      delete cssAnimations[animationName]
      
      if animation.onComplete?
        # trigger animation end callback
        ev = jQuery.Event animationEnd,
          animationName: animation.name
        el.trigger ev
      
      el.data({cssAnimations}).css(compileAnimations cssAnimations)

jQuery.fn.cssAnimate = (name, speed, easing, callback) ->
  {animationEnd} = jQuery.eventNames
  
  optall = jQuery.speed speed, easing, callback
  
  animation = { name }
  animation.duration = makeCSSTime optall.duration
  animation.delay    = makeCSSTime optall.delay, 0
  
  if typeof optall.old is 'function'
    callback = optall.old
  else
    callback = null
  
  animation.onComplete = (event) ->
    if event.animationName is animation.name
      $(this).unbind(event.type, animation.onComplete)
      callback?.call this, event
  
  this.each (i, el) ->
    cssAnimations = $(el).data('cssAnimations') ? {}
    cssAnimations[animation.name] = animation
    $(el)
    .data({cssAnimations})
    .css(compileAnimations cssAnimations)
    .bind(animationEnd, animation.onComplete)
