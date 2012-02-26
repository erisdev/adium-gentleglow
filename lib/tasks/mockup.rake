require 'sinatra/base'
require 'coffee-script'
require 'json'
require 'sass'
require 'open-uri'
require 'uri'
require 'yaml'

require_relative '../haml-coffee'
require_relative '../markov_chatterbot'

desc "start the mockup HTTP server"
task :mockup do
  class Mockup < Sinatra::Base
    enable :logging
    enable :lock
    set :public_folder, 'files'
    
    # mockup-specific routes
    
    get('/') do
      send_file 'mockup/mockup.html'
    end
    
    get('/mockup/scripts/:script.js') do
      coffee params[:script].to_sym, :views => 'mockup/scripts'
    end
    
    post('/chat') do
      chatterbot.input params[:message]
    end
    
    get('/chat') do
      chatterbot.output
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
    
    # message style routes
    
    get('/message_view') do
      stuff = [
        '/', 'main.css', 'Variants/RegularKind.css',
        (File.read('files/Header.html') rescue ''),
        (File.read('files/Footer.html') rescue '')
      ]
      vars = {
        :timeOpened => Time.now.strftime('%H:%M'),
        :sourceName => 'Me',
        :destinationName => 'Markov',
        :chatName => 'Preview Conversation',
        :incomingIconPath => 'incoming_icon.png'
      }
      File.read('files/Template.html')
      .gsub('%@') { stuff.shift }
      .gsub(/%(\w+)%/) { vars[$1.to_sym] }
    end
    
    %w[ scripts stylesheets Variants resources ].each do |dir|
      get("/#{dir}/*") do
        filename = 'build'/dir/params[:splat].first
        begin
          Rake.application[filename].invoke
          send_file filename
        rescue => ex
          status 404
          "#{ex}"
        end
      end
    end
    
    def chatterbot
      unless defined? @@chatterbot
        @@chatterbot = MarkovChatterbot.new
        # build the chatterbot's lexicon from README and CHANGELOG
        %w[README.mdown CHANGELOG.mdown].each do |filename|
          File.readlines(filename).each do |line|
            next if line.length == 0
            next if line.match /^#/
            next if line.match /^\[[^\]]+\]: /
            
            line.sub!  %r{^ \s* \* \s* }x, ''
            line.gsub! %r{ \[ ( .+ ) \] (?: \[ .* \] | \( .+ \) ) }x, '\\1'
            
            line.split(/ (?<= [\.\?\!] ) \s+ /x).each do |sentence|
              @@chatterbot.input sentence
            end
          end
        end
      end
      @@chatterbot
    end
    
    run!
  end
end
