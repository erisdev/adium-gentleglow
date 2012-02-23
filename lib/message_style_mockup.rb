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
    Tilt.new(path).render
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
  
  get('/scripts/modules.js') do
    output = []
    
    Dir['scripts/**/*.coffee'].reject{ |fn| /\b_/ =~ fn }.each do |filename|
      module_name = filename.match(%r(scripts/(.+)\.coffee$))[1]
      output << <<-"END_JS"
        define(#{module_name.to_json}, function(global, module, exports, require) {
          #{coffee module_name.to_sym}
        });
      END_JS
    end
    
    info = YAML.load_file 'package.yaml'
    info['environment'] =
    info['include-environment'].inject({}) do |vars, name|
      vars.merge! name => ENV[name]
    end
    
    output << 'define("message_style", function(global, module, exports, require) {'
    info.each do |key, value|
      output << "  exports[#{key.to_json}] = #{value.to_json};"
    end
    output << '});'
    
    output << 'define("resources", function(global, module, exports, require) {'
    output << coffee(:resources, :views => 'mockup/scripts')
    output << '});'
    
    content_type 'text/javascript'
    output.join "\n"
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
