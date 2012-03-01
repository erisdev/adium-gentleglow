exports = class ResourceManager
  constructor: ->
    @resources = {}
  
  get: (keypath) ->
    @resources[keypath]
  
  render: (keypath, vars = {}, fn) ->
    if not fn? and typeof vars is 'function'
      [vars, fn] = [{}, vars]
    
    vars = $.extend {}, vars,
      resources: this
      
      partial: ->
        @resources.render.apply this, arguments
      
      yield: ->
        fn.apply vars, arguments
    
    this.get(keypath)(vars)
  
  register: (keypath, value) ->
    @resources[keypath] = value
