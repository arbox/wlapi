# -*- mode: ruby; -*-
lib_path = File.expand_path(File.dirname(__FILE__) + '/lib')
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

require 'wlapi/version'
require 'time'

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
#require 'rake/testtask'
#Rake::TestTask.new do |t|
#  t.libs << 'test'
#  t.warning
#  t.ruby_opts = ['-rubygems']
#  t.test_files = FileList['test/*.rb']
#end

namespace :test do
  interpreter = 'ruby -rubygems -I lib -I test'
  task :local do
    sh "#{interpreter} test/local_*"
  end

  task :remote do
    sh "#{interpreter} test/remote_*"
  end
  
  task :all => [:local, :remote]
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
  sh "bundle exec gem push wlapi-#{WLAPI::VERSION}.gem"
end

desc 'Tag the current source code version.'
task :tag do
  # cb = current branch
  cb = `git branch`.split("\n").delete_if { |i| i !~ /[*]/ }
  puts cb.inspect
  cb = cb.first.sub('* ', '')

  if cb == 'master'
    system "git tag -am 'v#{WLAPI::VERSION}'"
  else
    STDERR.puts "We are on branch #{cb}. Please switch to master branch."
  end
end

desc 'Builds the .gem package.'
task :build do
  sh 'bundle exec gem build wlapi.gemspec'
end

desc 'Publish the documentation on the homepage.'
task :publish => [:clobber, :doc] do
  system "scp -r ydoc/* #{File.read('SENSITIVE').chomp}"
end

task :travis do
  message = "#{Time.now}\t#{WLAPI::VERSION}\n"
  File.open('.gem-version', 'w') do |file|
    file.write(message)
  end
  sh 'git add .gem-version'
  sh "git commit -m '#{message.chomp}'"
  sh 'git push origin master'
end

task :default => [:test]
