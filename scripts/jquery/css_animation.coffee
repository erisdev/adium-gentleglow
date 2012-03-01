jQuery.cssAnimationProperties =
  name: 'webkitAnimationName'
  delay: 'webkitAnimationDelay'
  direction: 'webkitAnimationDirection'
  duration: 'webkitAnimationDuration'
  easing: 'webkitAnimationTimingFunction'
  fillMode: 'webkitAnimationFillMode'
  iterations: 'webkitAnimationIterationCount'

jQuery.cssAnimationEvents =
  animationEnd: 'webkitAnimationEnd'

jQuery.cssAnimations =
  fadeIn: 'fx-fadeIn'
  fadeOut: 'fx-fadeOut'

makeCSSTime = (time, def) ->
  if not time?
    def
  else if typeof time is 'number' or /^\d+$/.test(time)
    "#{time}ms"
  else
    time

compileAnimations = (animations) ->
  {}.tap (css) ->
    for own propertyName, styleName of jQuery.cssAnimationProperties
      css[styleName] = (
        for own name, animation of animations
          value = animation[propertyName]
          if propertyName is 'delay' or propertyName is 'duration'
            makeCSSTime value, '0ms'
          else
            value ? 'initial'
      ).join ', '

createAnimation = (name, speed, easing, callback) ->
  options = jQuery.speed speed, easing, callback
  animation = { name }
  
  # Animation's first keyframe is applied immediately, before the delay, and
  # the final keyframe sticks after the animation ends. Do we really want it
  # any other way?
  options.fillMode ?= 'both'
  
  for own propertyName of jQuery.cssAnimationProperties when options[propertyName]?
    animation[propertyName] = options[propertyName]
  
  if typeof options.old is 'function'
    animation.onComplete = options.old
  
  animation

dontAnimate = (speed, easing, callback) ->
  options = jQuery.speed speed, easing, callback
  this.each((i, el) -> options.old.call el) if options.old
  this

addAnimation = (el, animation) ->
  cssAnimations = $(el).data('cssAnimations') ? {}
  cssAnimations[animation.name] = animation
  $(el).data({cssAnimations}).css(compileAnimations cssAnimations)

removeAnimation = (el, name) ->
  cssAnimations = $(el).data('cssAnimations')
  if animation = cssAnimations?[name]
    delete cssAnimations[name]
    animation.onComplete?.call el
  $(el).data({cssAnimations}).css(compileAnimations cssAnimations)

$('*').live jQuery.cssAnimationEvents.animationEnd, (event) ->
  removeAnimation this, event.originalEvent.animationName

jQuery.fn.cssFadeOut = (speed, easing, callback) ->
  if $.fx.off
    this.css display: 'none'
    return dontAnimate.call this, speed, easing, callback
  
  {fadeIn, fadeOut} = jQuery.cssAnimations
  animation = createAnimation fadeOut, speed, easing, callback
  
  oldCallback = animation.onComplete
  animation.onComplete = ->
    $(this).css 'display', 'none'
    oldCallback?.apply this, arguments
    
  $(this).cssStop(fadeIn).each (i, el) -> addAnimation el, animation

jQuery.fn.cssFadeIn = (speed, easing, callback) ->
  if $.fx.off
    this.css display: ''
    return dontAnimate.call this, speed, easing, callback
  
  {fadeIn, fadeOut} = jQuery.cssAnimations
  $(this)
  .cssStop(fadeOut)
  .css('display', '')
  .cssAnimate(fadeIn, speed, easing, callback)

jQuery.fn.cssStop = (animationName) ->
  return this if $.fx.off
  $(this).each (i, el) -> removeAnimation el, animationName

jQuery.fn.cssAnimate = (name, speed, easing, callback) ->
  return dontAnimate.call(this, speed, easing, callback) if $.fx.off
  
  animation = createAnimation name, speed, easing, callback
  this.each (i, el) -> addAnimation el, animation
