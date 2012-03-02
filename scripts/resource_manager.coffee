exports = class ResourceManager
  constructor: ->
    @resources = {}
  
  get: (keypath) ->
    @resources[keypath]
  
  render: (keypath, vars = {}, fn) ->
    template = this.get(keypath) ? this.get("#{keypath}/index")
    
    unless template? and typeof template is 'function'
      throw new Error "unable to load template #{keypath}"
    
    if not fn? and typeof vars is 'function'
      [vars, fn] = [{}, vars]
    
    vars = $.extend {}, vars,
      resources: this
      
      partial: (partialKeypath, partialVars = vars) ->
        if relativePath = partialKeypath.match(///^ \./ (.+) $///)?[1]
          base = keypath.replace /// / [^/]+ $///, ''
          partialKeypath = "#{base}/#{relativePath}"
          
        @resources.render partialKeypath, partialVars
      
      yield: ->
        fn.apply vars, arguments
    
    this.get(keypath)(vars)
  
  register: (keypath, value) ->
    @resources[keypath] = value
