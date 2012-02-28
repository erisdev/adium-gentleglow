require 'coffee-script'
require 'tilt'
require 'yaml'

require_relative '../haml-coffee'

RESOURCE_IN_FILES = FileList['resources/**/*.*']
RESOURCE_OUT_FILES = RESOURCE_IN_FILES.pathmap 'build/%X'

rule %r(/resources/) => [
  pathmapper('%{^build/,}X', :any_extension => true),
  pathmapper('%d/')
] do |t|
  source, target = t.source, t.name
  
  case source.extname
  when '.yaml'
    puts "[YAML] #{t.source} => #{t.name}"
    File.open(target, 'w') { |io| io << YAML.load_file(source).to_json }
  else
    template = Tilt.new(source)
    
    type = template.class.name.match(/ (?: :: )? (\w+) Template /x)[1]
    puts "[#{type}] #{source} => #{target}"
    
    File.open(target, 'w') { |io| io << template.render }
  end
end

file 'build/scripts/resources.js' => [
  *RESOURCE_OUT_FILES,
  'build/scripts/'
] do |t|
  puts "Compiling resources to #{t.name}"
  
  File.open(t.name, 'w') do |io|
    io << <<-END_JS
      var ResourceManager = require('resource_manager');
      exports = new ResourceManager();
    END_JS
    
    RESOURCE_OUT_FILES.each do |source|
      next unless File.file? source
      
      keypath = source.pathmap '%{^build/resources/,}X'
      io.puts "exports.register(#{keypath.to_json}, #{File.read source});"
    end
  end
end

task :compile => 'compile:resources'
task :clean => 'clean:resources'

namespace :compile do
  desc 'compile resources'
  task :resources => 'build/scripts/resources.js'
end

namespace :clean do
  desc 'remove compiled resources'
  task :resources do
    rm_rf 'build/resources'
  end
end
