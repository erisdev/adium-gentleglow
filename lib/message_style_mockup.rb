require 'sinatra/base'
require 'coffee-script'
require 'json'
require 'sass'
require 'open-uri'
require 'uri'
require 'yaml'

require_relative 'haml-coffee'
require_relative 'markov_chatterbot'

class MessageStyleMockup < Sinatra::Base
  enable :logging
  enable :lock
  set :public_folder, 'files'
  
  set :coffee, :views => 'scripts'
  set :sass, :views => 'stylesheets', :load_paths => %w[ stylesheets/lib ]
  
  # mockup-specific routes
  
  get('/') do
    send_file 'mockup/mockup.html'
  end
  
  get('/mockup/scripts/:script.js') do
    coffee params[:script].to_sym, :views => 'mockup/scripts'
  end
  
  post('/chat') do
    $markov_chainer.input params[:message]
  end
  
  get('/chat') do
    $markov_chainer.output
  end
  
  get('/ajax') do
    content_type = nil
    
    uri = URI.parse params[:_url]
    uri.query = [uri.query, URI.encode_www_form(params)].join('&')
    
    open(uri) do |f|
      content_type = f.content_type
      f.read
    end
  end
  
  get('/resources/*') do
    # find a file with the requested name and any extension
    path = Dir["resources/#{params[:splat].first}.*"].first
    type = File.extname(path)[1..-1].to_sym
    puts type.inspect
    case type
    when :haml then HamlCoffee.compile File.read path
    else send_file path
    end
  end
  
  # message style routes
  
  get('/message_view') do
    stuff = [
      '/', 'main.css', 'Variants/RegularKind.css',
      (File.read('files/Header.html') rescue ''),
      (File.read('files/Footer.html') rescue '')
    ]
    File.read('files/Template.html').gsub('%@') { stuff.shift }
  end
  
  get('/scripts/message-style.js') do
    info = YAML.load_file 'package.yaml'
    info['environment'] =
    info['include-environment'].inject({}) do |vars, name|
      vars.merge! name => ENV[name]
    end
    "window.MessageStyle = #{info.to_json};"
  end
  
  get('/scripts/resources.js') do
    coffee :resources, :views => 'mockup/scripts'
  end
  
  get(%r'/scripts/(.+).js') do
    coffee params[:captures].first.to_sym
  end
  
  get('/stylesheets/:stylesheet.css') do
    sass params[:stylesheet].to_sym
  end
  
  get('/Variants/:variant.css') do
    content_type :css
    body %Q{ @import url("../stylesheets/#{params[:variant]}.var.css"); }
  end
  
  # gross, but how else to do it?
  $markov_chainer = MarkovChatterbot.new
  
  # build the chatterbot's lexicon from README and CHANGELOG
  %w[README.mdown CHANGELOG.mdown].each do |filename|
    File.readlines(filename).each do |line|
      next if line.length == 0
      next if line.match /^#/
      next if line.match /^\[[^\]]+\]: /
      
      line.sub!  %r{^ \s* \* \s* }x, ''
      line.gsub! %r{ \[ ( .+ ) \] (?: \[ .* \] | \( .+ \) ) }x, '\\1'
      
      line.split(/ (?<= [\.\?\!] ) \s+ /x).each do |sentence|
        $markov_chainer.input sentence
      end
    end
  end
  
  run!
end
