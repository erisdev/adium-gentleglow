require 'execjs'
require 'coffee-script'

require_relative 'haml-coffee/haml_coffee_template.rb'

module HamlCoffee
  HAML_COFFEE_JS = File.expand_path 'haml-coffee/hamlcoffee.js', File.dirname(__FILE__)
  
  WRAPPER = <<-END_JS
    function compileTemplate(source, options) {
      var HamlCoffee = require('./haml-coffee.js');
      compiler = new HamlCoffee(options);
      compiler.parse(source);
      return compiler.precompile();
    }
  END_JS
  
  def self.compile source, options = {}
    @context ||= ExecJS.compile [File.read(HAML_COFFEE_JS), WRAPPER].join ";\n\n"
    
    options = {
      :escapeHtml => false,
      
      :customHtmlEscape      => 'window.HamlCoffeeHelpers.htmlEscape',
      :customCleanValue      => 'window.HamlCoffeeHelpers.cleanValue',
      :customPreserve        => 'window.HamlCoffeeHelpers.preserve',
      :customFindAndPreserve => 'window.HamlCoffeeHelpers.findAndPreserve',
      :customSurround        => 'window.HamlCoffeeHelpers.surround',
      :customSucceed         => 'window.HamlCoffeeHelpers.succeed',
      :customPrecede         => 'window.HamlCoffeeHelpers.precede'
    }.merge! options
    
    coffee = @context.call 'compileTemplate', source, options
    js = CoffeeScript.compile coffee, :bare => true
    
    "(function(context) {\nreturn (function() {\n#{js}\n}).call(context);\n})"
  end
end
