desc "start the mockup HTTP server"
task :mockup do
  sh 'ruby -Ilib lib/message_style_mockup.rb'
end