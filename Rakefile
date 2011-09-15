require 'less'
require 'yaml'
require 'json'

class String
  def / (other) File.join(self, other); end
  def basename(*args) File.basename(self, *args); end
end

def template_file template_path, output_path
  output = File.read template_path
  output.gsub!(%r( \$\{ ([^\}]+) \} )x) { PACKAGE_INFO[$1.gsub(/_/, '-')] }
  
  output_path = output_path / File.basename(template_path) \
    if File.directory? output_path
  
  File.open(output_path, 'w') { |io| io.write output }
end

PACKAGE_INFO    = YAML.load_file 'package.yaml'
BUNDLE_NAME     = "#{PACKAGE_INFO['package-name']}.AdiumMessageStyle"

BUILD_DIR       = 'build'
PACKAGE_DIR     = BUILD_DIR / PACKAGE_INFO['package-name']
BUNDLE_DIR      = PACKAGE_DIR / BUNDLE_NAME
CONTENTS_DIR    = BUNDLE_DIR / "Contents"
RESOURCES_DIR   = CONTENTS_DIR / 'Resources'

COFFEE_FILES    = FileList['scripts/**/*.coffee']
JS_FILES        = COFFEE_FILES.pathmap BUILD_DIR / '%X.js'

VARIANT_FILES   = FileList[ ]

PACKAGE_INFO['variants'].each do |name, files|
  output_name = BUILD_DIR / 'variants' / "#{name}.css"
  
  VARIANT_FILES << output_name
  file output_name => FileList[files, BUILD_DIR / 'variants'] do
    sh "lessc #{files.join ' '} > #{output_name}"
  end
end


task :default => :compile

desc 'compile scripts and stylesheets'
task :compile => %w[ compile:scripts compile:variants ]

desc 'remove all build products'
task :clean => %w[ clean:scripts clean:variants clean:package ]

namespace :compile do
  
  desc 'compile scripts'
  task :scripts => JS_FILES
  
  desc 'compile variant stylesheets'
  task :variants => [*VARIANT_FILES, BUILD_DIR / 'variants/variants.json']
  
end

desc 'package for distribution'
task :package => [:compile, PACKAGE_DIR, CONTENTS_DIR, RESOURCES_DIR] do
  package_name    = PACKAGE_INFO['package-name']
  package_version = PACKAGE_INFO['package-version']
  scripts_dir     = BUILD_DIR / 'scripts'
  variants_dir    = BUILD_DIR / 'variants'
  
  PACKAGE_INFO['include-files'].each do |file|
    if file.is_a? Hash
      file.each { |from, to| sh "cp #{from} #{PACKAGE_DIR / to}"}
    else
      sh "cp #{file} #{PACKAGE_DIR}"
    end
  end
  
  sh "rsync --recursive resources/ #{RESOURCES_DIR}"
  sh "rsync --recursive #{variants_dir} #{RESOURCES_DIR}" \
    if File.directory? variants_dir
  sh "rsync --recursive #{scripts_dir} #{RESOURCES_DIR}" \
    if File.directory? scripts_dir
  
  template_file 'templates/Info.plist', CONTENTS_DIR
  
  sh 'tar', 'jcf', BUILD_DIR / "#{package_name}-#{package_version}.tar.bz2",
    '-C', BUILD_DIR, package_name
end

desc "install to Adium's Message Styles folder"
task :install => :package do
  message_styles_dir = ENV['HOME'] / 'Library/Application Support/Adium 2.0/Message Styles'
  sh "rm -R '#{message_styles_dir / BUNDLE_NAME}'"
  sh "cp -R #{BUNDLE_DIR} '#{message_styles_dir}'"
end

namespace :clean do
  
  desc 'remove compiled scripts'
  task(:scripts) { system 'rm', '-f', *JS_FILES.existing }
  
  desc 'remove compiled variant stylesheets'
  task(:variants) { system 'rm', '-f', *VARIANT_FILES.existing }
  
  desc 'remove distribution package'
  task(:package) { system 'rm', '-R', 'build' if File.exist? 'build' }
  
end

directory BUILD_DIR
directory BUILD_DIR / 'scripts'
directory BUILD_DIR / 'variants'
directory PACKAGE_DIR
directory CONTENTS_DIR
directory RESOURCES_DIR

file BUILD_DIR / 'variants/variants.json' do |t|
  File.open(t.name, 'w') { |io| io.write PACKAGE_INFO['variants'].keys.to_json }
end

def pathmap spec
  proc { |file| file.pathmap spec }
end

rule %r(\.js$) => [pathmap("%{^build/,}d/%n.coffee"), BUILD_DIR / 'scripts'] do |t|
  sh "coffee -o #{File.dirname t.name} -c #{t.source}"
end
