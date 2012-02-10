require 'sinatra/base'
require 'coffee-script'
require 'json'
require 'sass'
require 'open-uri'
require 'uri'
require 'yaml'

class MessageStyleMockup < Sinatra::Base
  enable :logging
  enable :lock
  set :public_folder, 'resources'
  
  set :coffee, :views => 'scripts'
  set :sass, :views => 'stylesheets', :load_paths => %w[ stylesheets/lib ]
  
  # mockup-specific routes
  
  get('/') do
    send_file 'mockup/mockup.html'
  end
  
  get('/mockup/scripts/:script.js') do
    coffee params[:script].to_sym, :views => 'mockup/scripts'
  end
  
  get('/ajax') do
    content_type = nil
    
    uri = URI.parse params[:_url]
    uri.query = URI.encode_www_form params
    
    open(uri) do |f|
      content_type = f.content_type
      f.read
    end
  end
  
  # message style routes
  
  get('/message_view') do
    stuff = [
      '/', 'main.css', 'Variants/RegularKind.css',
      (File.read('resources/Header.html') rescue ''),
      (File.read('resources/Footer.html') rescue '')
    ]
    File.read('resources/Template.html').gsub('%@') { stuff.shift }
  end
  
  get('/scripts/message-style.js') do
    info = YAML.load_file 'package.yaml'
    info['environment'] =
    info['include-environment'].inject({}) do |vars, name|
      vars.merge! name => ENV[name]
    end
    "window.MessageStyle = #{info.to_json};"
  end
  
  get(%r'/scripts/(.+).js') do
    coffee params[:captures].first.to_sym
  end
  
  get('/Variants/:variant.css') do
    sass "#{params[:variant]}.var".to_sym
  end
  
  run!
end
