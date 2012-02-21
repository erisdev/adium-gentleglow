require 'sass'

SASS_FILES    = FileList['stylesheets/**/*.{scss,sass}']
CSS_FILES     = FileList['stylesheets/*.{scss,sass}'].pathmap 'build/%X.css'
VARIANT_FILES = FileList['stylesheets/*.var.{scss,sass}'].pathmap 'build/Variants/%{.var$,}n.css'

rule %r(Variants/.+\.css$) => [
  pathmapper('%d/')
] do |t|
  variant = t.name.basename '.css'
  
  puts "[Variant] #{variant} => #{t.name}"
  
  File.open(t.name, 'w') do |io|
    io.puts %Q{@import url("../stylesheets/#{variant}.var.css");}
  end
end

rule %r(stylesheets/.+\.css$) => [
  pathmapper('%{^build/,}d/%n.sass'),
  pathmapper('%d/'),
  *SASS_FILES # ugh, yuck, but dependency extraction is expensive too
] do |t|
  puts "[SASS] #{t.source} => #{t.name}"
  Sass.compile_file t.source, t.name, :load_paths => %w[ stylesheets/lib ]
end

task :compile => 'compile:stylesheets'
task :clean => 'clean:stylesheets'

namespace :compile do
  desc 'compile stylesheets'
  task :stylesheets => [*CSS_FILES, *VARIANT_FILES]
end

namespace :clean do
  desc 'remove compiled stylesheets'
  task :stylesheets do
    rm_rf 'build/stylesheets'
    rm_rf 'build/Variants'
  end
end
