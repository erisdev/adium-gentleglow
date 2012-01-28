require 'coffee-script'
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
LESS_FILES      = FileList['stylesheets/lib/**/*.less']
LESS_PATH       = %w[ stylesheets/lib ]

PACKAGE_INFO['environment'] =
PACKAGE_INFO['include-environment'].inject({}) do |vars, name|
  vars.merge! name => ENV[name]
end

PACKAGE_INFO['variants'].each do |variant_name, input_file|
  output_file = BUILD_DIR / 'variants' / "#{variant_name}.css"
  VARIANT_FILES << output_file
  
  file output_file => [input_file, *LESS_FILES, BUILD_DIR / 'variants'] do
    $stderr.puts "Compile variant #{variant_name}"
    
    parser = Less::Parser.new :paths => LESS_PATH, :filename => output_file
    tree = parser.parse File.read(input_file)
    File.open(output_file, 'w') { |io| io.write tree.to_css }
  end
end

Dir['lib/tasks/*.rake'].each { |f| load f }

task :default => :compile

desc 'compile scripts and stylesheets'
task :compile => %w[ compile:scripts compile:variants ]

desc 'remove all build products'
task :clean => %w[ clean:scripts clean:variants clean:package ]

namespace :compile do
  
  desc 'compile scripts'
  task :scripts => [*JS_FILES, BUILD_DIR / 'scripts/message-style.js']
  
  desc 'compile variant stylesheets'
  task :variants => VARIANT_FILES
  
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

def pathmap spec
  proc { |file| file.pathmap spec }
end

file BUILD_DIR / 'scripts/message-style.js' => 'package.yaml' do |t|
  puts "writing package info to #{t.name}"
  File.open(t.name, 'w') { |io| io.puts "window.MessageStyle = #{PACKAGE_INFO.to_json}" }
end

rule %r(\.js$) => [pathmap("%{^build/,}d/%n.coffee"), BUILD_DIR / 'scripts'] do |t|
  dir = File.dirname t.name
  mkdir_p dir unless File.exist? dir
  
  $stderr.puts "coffee -o #{File.dirname t.name} -c #{t.source}"
  
  js = File.open(t.source) do |io|
    # I wish there was a :helpers => false option!
    CoffeeScript.compile io, :filename => t.name
  end
  
  File.open(t.name, 'w') { |io| io.write js }
end
