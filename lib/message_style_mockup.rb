require 'sinatra/base'
require 'coffee-script'
require 'json'
require 'less'
require 'yaml'

class Tilt::LessTemplate
  def prepare
    # We're monkey patching this method to actually pass options to the new
    # Less parser. The old parser is old and dumb, so forget it.
    parser  = ::Less::Parser.new(options.merge :filename => eval_file, :line => line)
    @engine = parser.parse(data)
  end
end

class MessageStyleMockup < Sinatra::Base
  enable :logging
  enable :lock
  set :public_folder, 'resources'
  
  set :coffee, :views => 'scripts'
  set :less, :views => 'stylesheets', :paths => %w[ stylesheets/lib ]
  
  # mockup-specific routes
  
  get('/') do
    send_file 'mockup/mockup.html'
  end
  
  get('/mockup/scripts/:script.js') do
    coffee params[:script].to_sym, :views => 'mockup/scripts'
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
    stylesheet = params[:variant].gsub(/(?<=[[:lower:]])(?=[[:upper:]])/, '-').downcase!
    less stylesheet.to_sym
  end
  
  run!
end
