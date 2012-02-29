require 'yaml'

class String
  
  def / other
    File.join self, other.to_s
  end
  
  def extname
    File.extname self
  end
  
  def dirname
    File.dirname self
  end
  
  def basename *args
    File.basename self, *args
  end
  
end

def pathmapper spec, options = {}
  if options[:any_extension]
    proc { |filename| Dir["#{filename.pathmap(spec)}{,.*}"].first }
  else
    proc { |filename| filename.pathmap spec }
  end
end

PACKAGE_INFO = YAML.load_file 'package.yaml'

ENV.each do |var, value|
  case var
  when /^(\w+)_key$/i
    service = $1.downcase
    puts "adding #{var} as an API key"
    PACKAGE_INFO['api-keys'][service] = value
  end
end

task :default => :package

desc 'compile scripts and stylesheets'
task :compile

desc 'remove all build products'
task :clean

# semi-automagically create directories
rule('/') { |t| mkdir_p t.name }

Dir['lib/tasks/*.rake'].each { |f| load f }
