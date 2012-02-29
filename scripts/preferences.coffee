Console = require 'console'
resources = require 'resources'

storage = global.localStorage
namespace = 'preferences'

specs = resources.get 'data/preferences'

types =
  boolean: (val) -> if val then true else false
  number: (val) -> +val
  string: (val) -> "#{val}"

exports.get = (key) ->
  if spec = specs[key]
    if value = storage.getItem "#{namespace}:#{key}"
      JSON.parse value
    else
      spec.default
  else
    Console.warn "invalid preference key #{key}"
    return

exports.set = (key, newValue) ->
  if spec = specs[key]
    oldValue = this.get key
    
    if newValue?
      storage.setItem "#{namespace}:#{key}", JSON.stringify(newValue)
    else
      storage.removeItem "#{namespace}:#{key}"
    
    $(window).trigger jQuery.Event 'gg:preferences',
      { key, oldValue, newValue }
  else
    Console.warn "invalid preference key #{key}"
    return

exports.label = (key) -> specs[key]?.label
  
exports.each = (options, fn) ->
  [options, fn] = [null, options] if arguments.length < 2
  for key, spec of specs
    if options?.values
      fn key, spec, this.get(key)
    else
      fn key, spec

exports.panel =
  toggle: ->
    if $('#gg-preferences').is(':visible')
      this.hide()
    else
      this.show()
  
  show: ->
    panel = $('#gg-preferences')
    if panel.length is 0
      template = resources.get 'views/preferences'
      panel = $(template preferences: exports).appendTo 'body'
      
      # immediately modify preferences on click
      panel.find('input').bind 'click', (event) ->
        input = $(this)
        key = input.attr('name')
        console.log [key, input.val()]
        exports.set key, input.val()
    
    panel.cssFadeIn()
  
  hide: ->
    $('#gg-preferences').cssFadeOut()
