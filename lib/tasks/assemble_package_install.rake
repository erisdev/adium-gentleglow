BUNDLE_NAME  = "#{PACKAGE_INFO['package-name']}.AdiumMessageStyle"
ARCHIVE_NAME = "#{PACKAGE_INFO['package-name']}-#{PACKAGE_INFO['package-version']}.tar.bz2"

INSTALL_DIR  = ENV['HOME']/'Library/Application Support/Adium 2.0/Message Styles'

def template_file template_path, output_path
  output = File.read template_path
  output.gsub!(%r( \$\{ ([^\}]+) \} )x) { PACKAGE_INFO[$1.gsub(/_/, '-')] }
  
  output_path = output_path / File.basename(template_path) \
    if File.directory? output_path
  
  File.open(output_path, 'w') { |io| io.write output }
end

desc 'assemble the message style bundle for packaging or installation'
task :assemble => [:compile, 'dist/'] do
  begin
    require 'uglifier'
  rescue LoadError
    puts "Uglifier is not available. JavaScript won't be minified."
  end
  
  package_name    = PACKAGE_INFO['package-name']
  package_version = PACKAGE_INFO['package-version']
  
  PACKAGE_INFO['include-files'].each do |file|
    if file.is_a? Hash
      file.each { |from, to| cp from, 'dist'/to }
    else
      cp file, 'dist'
    end
  end
  
  contents_dir = 'dist'/BUNDLE_NAME/'Contents'
  mkdir_p contents_dir
  
  template_file 'templates/Info.plist', contents_dir
  
  resources_dir = contents_dir/'Resources'
  mkdir_p resources_dir
  
  FileList[%w[
    files/**/*
    build/Variants/**/*
    build/stylesheets/*
    build/scripts/_require.js
    build/scripts/modules.js
  ]].reject do |source|
    # skip directories
    File.directory? source
  end.each do |source|
    target = source.pathmap "%{^(build|files),#{resources_dir}}p"
    dir = target.dirname
    
    mkdir_p dir unless File.directory? dir
    
    if File.exist?(target) and File.mtime(target) > File.mtime(source)
      puts "[SKIP] #{source}"
      next
    elsif source.extname == '.js' and defined? Uglifier
      puts "[Uglifier] #{source} => #{target}"
      File.open(target, 'w') { |io| io << Uglifier.compile(File.read source) }
    else
      cp source, target
    end
  end
  
end

desc 'package for distribution'
task :package => :assemble do
  sh 'tar', 'jcf', ARCHIVE_NAME, '-s', '/^dist/GentleGlow/', 'dist'
end

desc "install to Adium's Message Styles folder"
task :install => :assemble do
  rm_rf INSTALL_DIR/BUNDLE_NAME
  cp_r 'dist'/BUNDLE_NAME, INSTALL_DIR
end

namespace :clean do
  
  desc 'remove assembled bundle'
  task :assemble do
    rm_rf 'dist'
  end
  
  desc 'remove distribution package'
  task :package do
    rm_f ARCHIVE_NAME
  end
  
end
