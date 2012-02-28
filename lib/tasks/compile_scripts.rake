require 'coffee-script'
require 'json'

COFFEE_FILES = FileList['scripts/**/*.coffee']
JS_FILES     = COFFEE_FILES.pathmap 'build/%X.js'

JS_FILES << 'build/scripts/message_style.js'
JS_FILES << 'build/scripts/resources.js'


rule %r(scripts/.+\.js) => [
  pathmapper("%{^build/,}X.coffee"),
  pathmapper('%d/')
] do |t|
  puts "[CoffeeScript] #{t.source} => #{t.name}"
  
  js = File.open(t.source) do |io|
    # I wish there was a :helpers => false option!
    CoffeeScript.compile io,
      :filename => t.source,
      :bare => !t.name.match(/\b_/) # don't wrap modules in a redundant closure
  end
  
  File.open(t.name, 'w') { |io| io.write js }
end

file 'build/scripts/modules.js' => JS_FILES do |t|
  puts "combining modules into #{t.name}"
  
  File.open(t.name, 'w') do |output|
    JS_FILES.reject{ |fn| /\b_/ =~ fn }.each do |filename|
      module_name = filename.pathmap '%{^build/scripts/,}X'
      output << <<-"END_JS"
        define(#{module_name.to_json}, function(global, module, exports, require) {
          #{File.read filename}
          return exports;
        });
      END_JS
    end
  end
end

file 'build/scripts/message_style.js' => 'package.yaml' do |t|
  puts "writing package info to #{t.name}"
  File.open(t.name, 'w') do |io|
    PACKAGE_INFO.each do |key, value|
      io.puts "exports[#{key.to_json}] = #{value.to_json};"
    end
  end
end

task :compile => 'compile:scripts'
task :clean => 'clean:scripts'

namespace :compile do
  desc 'compile scripts'
  task :scripts => [*JS_FILES, 'build/scripts/modules.js' ]
end

namespace :clean do
  desc 'remove compiled scripts'
  task :scripts do
    rm_rf 'build/scripts'
  end
end
