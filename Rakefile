require 'less'

PROJECT_NAME    = 'GentleGlow'

COFFEE_PATTERNS = [ %r(^ (.+) /js/     (.+) \.js     $)ix, '\1/coffee/\2.coffee',
                    %r(^ (.+) /coffee/ (.+) \.coffee $)ix, '\1/js/\2.js' ]
LESS_PATTERNS   = [ %r(^ (.+) /css/    (.+) \.css    $)ix, '\1/less/\2.less',
                    %r(^ (.+) /less/   (.+) \.less   $)ix, '\1/css/\2.css' ]

COFFEE_FILES    = Dir['Contents/Resources/coffee/**/*.coffee']
JS_FILES        = COFFEE_FILES.map { |s| s.sub *COFFEE_PATTERNS[2, 2] }

LESS_FILES      = Dir['Contents/Resources/less/**/*.coffee']
CSS_FILES       = LESS_FILES.map { |s| s.sub *LESS_PATTERNS[2, 2] }

PACKAGE_INCLUDE = %W[ CHANGELOG.1337.txt
                      CHANGELOG.mdown
                      README.1337.txt
                      README.mdown]

PACKAGE_EXCLUDE = %w[ Contents/Resources/coffee
                      Contents/Resources/less ]

task :default => :compile

desc 'compile scripts and stylesheets'
task :compile => ['compile:scripts', 'compile:styles']

desc 'remove all build products'
task :clean => ['clean:scripts', 'clean:styles', 'clean:package']

namespace :compile do
  
  desc 'compile scripts'
  task :scripts => JS_FILES
  
  desc 'compile stylesheets'
  task :styles  => CSS_FILES
  
end

desc 'package for distribution'
task :package => :compile do
  package_dir = "build/#{PROJECT_NAME}"
  style_name = "#{PROJECT_NAME}.adiumMessageStyle"
  
  system 'mkdir', '-p', package_dir
  system 'cp', *PACKAGE_INCLUDE, package_dir
  
  system 'mkdir', '-p', "#{package_dir}/#{style_name}"
  system 'rsync', '--archive', '--verbose',
    *PACKAGE_EXCLUDE.map { |file| "--exclude=#{file}" },
    'Contents', "#{package_dir}/#{style_name}"
  
  system 'tar', 'vjcf', "build/#{PROJECT_NAME}.tar.bz2",
    '-C', 'build', PROJECT_NAME
end

namespace :clean do
  
  existing = proc { |file| File.exist? file }
  
  desc 'remove compiled scripts'
  task(:scripts) { system 'rm', '-f', *JS_FILES.select(&existing) }
  
  desc 'remove compiled stylesheets'
  task(:styles) { system 'rm', '-f', *CSS_FILES.select(&existing) }
  
  desc 'remove distribution package'
  task(:package) { system 'rm', '-R', 'build' if File.exist? 'build' }
  
end

rule COFFEE_PATTERNS[0] => [
  proc { |s| s.sub *COFFEE_PATTERNS[0, 2] }
] do |t|
  system 'coffee', '-o', File.dirname(t.name), '-c', t.source
end

rule LESS_PATTERNS[0] => [
  proc { |s| s.sub *LESS_PATTERNS[0, 2] }
] do |t|
  system "lessc #{t.source} > #{t.name}"
end
