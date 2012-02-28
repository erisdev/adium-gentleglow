ResourceManager = require 'resource_manager'
exports = new ResourceManager

# Instead of compiling resources, monkey patch the resource manager to use
# AJAX to retrieve them.
exports.get = (path) ->
  resource = null
  $.ajax "/resources/#{path}",
    async: false
    error: (xhr, status, error) -> throw error
    success: (data) ->
      if /^\(?function\(/.test data
        resource = window.eval "(#{data})"
      else
        resource = data
  resource
