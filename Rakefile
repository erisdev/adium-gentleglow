require 'less'
require 'yaml'

class String
  def / (other) File.join(self, other); end
end

def template_file template_path, output_path
  output = File.read template_path
  output.gsub!(%r( \$\{ ([^\}]+) \} )x) { PACKAGE_INFO[$1.gsub(/_/, '-')] }
  
  output_path = output_path / File.basename(template_path) \
    if File.directory? output_path
  
  File.open(output_path, 'w') { |io| io.write output }
end

PACKAGE_INFO    = YAML.load_file 'package.yaml'

BUILD_DIR       = 'build'
PACKAGE_DIR     = BUILD_DIR / PACKAGE_INFO['package-name']
CONTENTS_DIR    = PACKAGE_DIR / "#{PACKAGE_INFO['package-name']}.AdiumMessageStyle/Contents"
RESOURCES_DIR   = CONTENTS_DIR / 'Resources'

COFFEE_FILES    = FileList['scripts/**/*.coffee']
JS_FILES        = COFFEE_FILES.pathmap BUILD_DIR / '%X.js'

LESS_FILES      = FileList['stylesheets/**/*.less']
CSS_FILES       = LESS_FILES.pathmap BUILD_DIR / '%X.css'

task :default => :compile

desc 'compile scripts and stylesheets'
task :compile => %w[ compile:scripts compile:styles ]

desc 'remove all build products'
task :clean => %w[ clean:scripts clean:styles clean:package ]

namespace :compile do
  
  desc 'compile scripts'
  task :scripts => JS_FILES
  
  desc 'compile stylesheets'
  task :styles  => CSS_FILES
  
end

desc 'package for distribution'
task :package => [:compile, PACKAGE_DIR, CONTENTS_DIR, RESOURCES_DIR] do
  package_name    = PACKAGE_INFO['package-name']
  package_version = PACKAGE_INFO['package-version']
  scripts_dir     = BUILD_DIR / 'scripts'
  stylesheets_dir = BUILD_DIR / 'stylesheets'
  
  PACKAGE_INFO['include-files'].each do |file|
    if file.is_a? Hash
      file.each { |from, to| sh "cp #{from} #{PACKAGE_DIR / to}"}
    else
      sh "cp #{file} #{PACKAGE_DIR}"
    end
  end
  
  sh "rsync --recursive resources/ #{RESOURCES_DIR}"
  sh "rsync --recursive #{stylesheets_dir} #{RESOURCES_DIR}" \
    if File.directory? stylesheets_dir
  sh "rsync --recursive #{scripts_dir} #{RESOURCES_DIR}" \
    if File.directory? scripts_dir
  
  template_file 'templates/Info.plist', CONTENTS_DIR
  
  sh 'tar', 'jcf', BUILD_DIR / "#{package_name}-#{package_version}.tar.bz2",
    '-C', BUILD_DIR, package_name
end

namespace :clean do
  
  desc 'remove compiled scripts'
  task(:scripts) { system 'rm', '-f', *JS_FILES.existing }
  
  desc 'remove compiled stylesheets'
  task(:styles) { system 'rm', '-f', *CSS_FILES.existing }
  
  desc 'remove distribution package'
  task(:package) { system 'rm', '-R', 'build' if File.exist? 'build' }
  
end

directory BUILD_DIR
directory BUILD_DIR / 'scripts'
directory BUILD_DIR / 'stylesheets'
directory PACKAGE_DIR
directory CONTENTS_DIR
directory RESOURCES_DIR

def pathmap spec
  proc { |file| file.pathmap spec }
end

rule %r(\.css$) => [pathmap('%-1d/%n.less'), BUILD_DIR / 'stylesheets'] do |t|
  sh "lessc #{t.source} > #{t.name}"
end

rule %r(\.js$) => [pathmap('%-1d/%n.coffee'), BUILD_DIR / 'scripts'] do |t|
  sh "coffee -o #{File.dirname t.name}, -c #{t.source}"
end
