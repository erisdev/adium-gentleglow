require 'yaml'

class String
  
  def / other
    File.join self, other.to_s
  end
  
  def basename *args
    File.basename self, *args
  end
  
end

def pathmapper spec
  proc { |file| file.pathmap spec }
end

PACKAGE_INFO = YAML.load_file 'package.yaml'

PACKAGE_INFO['environment'] =
PACKAGE_INFO['include-environment'].inject({}) do |vars, name|
  vars.merge! name => ENV[name]
end

task :default => :package

desc 'compile scripts and stylesheets'
task :compile

desc 'remove all build products'
task :clean

# semi-automagically create directories
rule('/') { |t| mkdir_p t.name }

Dir['lib/tasks/*.rake'].each { |f| load f }
