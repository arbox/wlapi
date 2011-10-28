lib_path = File.expand_path(File.dirname(__FILE__) + '/lib')
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

# Rake provides FileUtils and its own FileUtils extensions
require 'rake'
require 'rake/clean'

CLEAN.include('.*~')
CLOBBER.include('ydoc',
                'rdoc',
                '.yardoc',
                '*.gem')

# Generate documentation.
require 'rdoc/task'
RDoc::Task.new do |rdoc|
  rdoc.rdoc_files.include('README.rdoc',
                          'LICENSE.rdoc',
                          'CHANGELOG.rdoc',
                          'lib/**/*'
                          )
  rdoc.rdoc_dir = 'rdoc'
end

require 'yard'
YARD::Rake::YardocTask.new do |ydoc|
  ydoc.options += ['-o', 'ydoc']
  ydoc.name = 'ydoc'
end


# Testing.
require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.warning
  t.ruby_opts = ['-rubygems']
  t.test_files = FileList['test/*.rb']
end



desc 'Open an irb session preloaded with this library.'
task :console do
  sh 'irb -rubygems -I lib -r wlapi'
end

desc 'Show the current version.'
task :v do
  load 'wlapi/version.rb'
  puts WLAPI::VERSION
end

desc 'Document the code using Yard and RDoc.'
task :doc => [:clobber, :rdoc, :ydoc]
  
desc 'Release the library.'
task :release => [:tag, :build, :publish] do
  
end

desc 'Tag the current source code version.'
task :tag do
  puts 'Tagging the version.'
end

desc 'Builds the .gem package.'
task :build do
  puts 'Building the package.'
end

desc 'Publish the documentation on the homepage.'
task :publish => [:clobber, :doc] do
  system 'scp -r rdoc/* arbox@rubyforge.org:/var/www/gforge-projects/wlapi'
end

