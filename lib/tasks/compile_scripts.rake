require 'coffee-script'
require 'json'

COFFEE_FILES = FileList['scripts/**/*.coffee']
JS_FILES     = COFFEE_FILES.pathmap 'build/%X.js'

rule %r(\.js$) => [
  pathmapper("%{^build/,}X.coffee"),
  pathmapper('%d/')
] do |t|
  puts "[CoffeeScript] #{t.source} => #{t.name}"
  
  js = File.open(t.source) do |io|
    # I wish there was a :helpers => false option!
    CoffeeScript.compile io, :filename => t.name
  end
  
  File.open(t.name, 'w') { |io| io.write js }
end

file 'build/scripts/message-style.js' => 'package.yaml' do |t|
  puts "writing package info to #{t.name}"
  File.open(t.name, 'w') do |io|
    io.puts "window.MessageStyle = #{PACKAGE_INFO.to_json}"
  end
end

task :compile => 'compile:scripts'
task :clean => 'clean:scripts'

namespace :compile do
  desc 'compile scripts'
  task :scripts => [*JS_FILES, 'build/scripts/message-style.js']
end

namespace :clean do
  desc 'remove compiled scripts'
  task :scripts do
    rm_rf 'build/scripts'
  end
end
