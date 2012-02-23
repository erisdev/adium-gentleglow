begin
  require 'tilt/template'
  
  module HamlCoffee
    class HamlCoffeeTemplate < Tilt::Template
      self.default_mime_type = 'text/html'
      
      def self.engine_initialized?
        defined? ::HamlCoffee
      end
      
      def initialize_engine
        require_template_library 'haml-coffee'
      end
      
      def prepare
      end
      
      def evaluate scope, locals, &block
        @output ||= HamlCoffee.compile data, options
      end
      
      Tilt.register self, '.hamlc'
    end
  end
  
rescue LoadError
end
