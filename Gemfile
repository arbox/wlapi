# -*- mode: ruby -*-
source "http://rubygems.org"

# Recent Nokogiri versions (>= 1.6) dropped support for Ruby 1.8.7. It
# is a possible workaround, but we need a mature solution.
# Nokogiri 1.5.10 is the last version supporting Ruby 1.8.7.
# Now added Nokogiri 1.5.11.
if RUBY_VERSION =~ /1.8/
  gem 'nokogiri', '~> 1.5.0'
end

gemspec

group :development do
  gem 'flay'
  gem 'travis-lint'
  gem 'webmock'
  gem 'pry'
  gem 'vcr'
end
