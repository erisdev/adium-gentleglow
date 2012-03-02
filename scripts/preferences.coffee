Console = require 'console'
resources = require 'resources'
UIPanel = require 'ui/panel'

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

exports.panel = new UIPanel 'views/preferences',
  title: 'Preferences'
  id: 'gg-preferencePanel'
  parameters: { preferences: exports }

$(exports.panel).bind 'ui:load', (event) ->
  event.rootElement
  .find('input:checkbox').bind 'change', (event) ->
    exports.set $(this).attr('name'), $(this).is(':checked')
  .end()
  .find('input:not(*:checkbox)').bind 'change', (event) ->
    exports.set $(this).attr('name'), $(this).val()

