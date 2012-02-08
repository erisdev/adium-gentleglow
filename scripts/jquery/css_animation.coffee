jQuery.cssAnimationProperties =
  name: 'webkitAnimationName'
  delay: 'webkitAnimationDelay'
  direction: 'webkitAnimationDirection'
  duration: 'webkitAnimationDuration'
  easing: 'webkitAnimationTimingFunction'
  fillStyle: 'webkitAnimationFillStyle'
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
  
  for own propertyName of jQuery.cssAnimationProperties when options[propertyName]?
    animation[propertyName] = options[propertyName]
  
  if typeof options.old is 'function'
    animation.onComplete = options.old
  
  animation

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
  console.log "animation ended for #{event.target}"
  removeAnimation this, event.originalEvent.animationName

jQuery.fn.cssFadeOut = (speed, easing, callback) ->
  {fadeIn, fadeOut} = jQuery.cssAnimations
  animation = createAnimation fadeOut, speed, easing, callback
  
  oldCallback = animation.onComplete
  animation.onComplete = ->
    $(this).css 'display', 'none'
    oldCallback.apply this, arguments
    
  $(this).cssStop(fadeIn).each (i, el) -> addAnimation el, animation

jQuery.fn.cssFadeIn = (speed, easing, callback) ->
  {fadeIn, fadeOut} = jQuery.cssAnimations
  $(this)
  .cssStop(fadeOut)
  .css('display', '')
  .cssAnimate(fadeIn, speed, easing, callback)

jQuery.fn.cssStop = (animationName) ->
  $(this).each (i, el) -> removeAnimation el, animationName

jQuery.fn.cssAnimate = (name, speed, easing, callback) ->
  animation = createAnimation name, speed, easing, callback
  this.each (i, el) -> addAnimation el, animation
