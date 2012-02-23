require 'coffee-script'
require 'tilt'
require 'yaml'

require_relative '../haml-coffee'

RESOURCE_IN_FILES = FileList['resources/**/*.*']
RESOURCE_OUT_FILES = RESOURCE_IN_FILES.pathmap 'build/%X'

common_deps = [
  pathmapper('%{^build/,}X', :any_extension => true),
  pathmapper('%d/')
]

rule %r(/resources/.+\.yaml) => common_deps do |t|
  puts "[YAML] #{t.source} => #{t.name}"
  File.open(t.name, 'w') { |io| io << YAML.load_file(t.source).to_json }
end

rule %r(/resources/) => common_deps do |t|
  template = Tilt.new(t.source)
  
  type = template.class.name.match(/ (?: :: )? (\w+) Template /x)[1]
  puts "[#{type}] #{t.source} => #{t.name}"
  
  File.open(t.name, 'w') { |io| io << template.render }
end

file 'build/scripts/resources.js' => [
  *RESOURCE_OUT_FILES,
  'build/scripts/'
] do |t|
  puts "Compiling resources to #{t.name}"
  
  File.open(t.name, 'w') do |io|
    io.puts 'var res, ResourceManager;'
    io.puts 'ResourceManager = require("resource_manager").ResourceManager;'
    io.puts 'exports.resources = res = new ResourceManager();'
    
    RESOURCE_OUT_FILES.each do |source|
      next unless File.file? source
      
      keypath = source.pathmap '%{^build/resources/,}X'
      io.puts "  res.register(#{keypath.to_json}, #{File.read source});"
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
