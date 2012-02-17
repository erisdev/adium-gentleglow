require 'coffee-script'

require_relative '../haml-coffee'

RESOURCE_FILES = FileList['resources/**/*']

namespace :compile do
  task :resources => BUILD_DIR / 'scripts/resources.js'
end

file BUILD_DIR / 'scripts/resources.js' => RESOURCE_FILES do |t|
  mkdir_p BUILD_DIR / 'scripts'

  $stderr.puts "Compiling resources to #{t.name}"
  
  File.open(t.name, 'w') do |io|
    io.puts '(function() {'
    io.puts '  var res;'
    io.puts '  this.resources = res = new ResourceManager();'
    
    RESOURCE_FILES.each do |source|
      next unless File.file? source
      
      data = File.read source
      keypath = source.pathmap '%{^resources/,}d/%n'
      
      value = case File.extname(source)[1..-1].to_sym
      when :haml then HamlCoffee.compile data, :filename => source
      when :json then data # copy JSON verbatim
      else data.to_json
      end
      
      io.puts "  res.register(#{keypath.to_json}, #{value});"
    end
    
    io.puts '})()'
  end
end
