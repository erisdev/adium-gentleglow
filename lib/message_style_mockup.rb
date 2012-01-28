require 'sinatra/base'
require 'coffee-script'
require 'less'

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
  set :public_folder, 'resources'
  
  set :coffee, :views => 'scripts'
  set :less, :views => 'stylesheets', :paths => %w[ stylesheets/lib ]
  
  get('/') do
    send_file 'mockup/mockup.html'
  end
  
  get('/message_view') do
    stuff = [
      '/', 'main.css', 'Variants/RegularKind.css',
      (File.read('resources/Header.html') rescue ''),
      (File.read('resources/Footer.html') rescue '')
    ]
    File.read('resources/Template.html').gsub('%@') { stuff.shift }
  end
  
  get('/scripts/:script.js') do
    coffee params[:script].to_sym
  end
  
  get('/Variants/:variant.css') do
    stylesheet = params[:variant].gsub(/(?<=[[:lower:]])(?=[[:upper:]])/, '-').downcase!
    less stylesheet.to_sym
  end
  
  run!
end
