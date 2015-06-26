lib_path = File.expand_path(File.dirname(__FILE__) + '/lib')
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

require 'rake'
require 'wlapi/version'

# Define a constant here to use this spec in the Rakefile.
Gem::Specification.new do |s|
  s.name = 'wlapi'
  # it is the description for 'gem list -d'
  s.summary = 'WLAPI is a programmatic API for web services provided by the'\
              'project Wortschatz, University of Leipzig. Use different'\
              'linguistic services such as synonym and collocation search.'
  s.description = 'WLAPI is a programmatic API for web services provided'\
                  'by the project Wortschatz, University of Leipzig. These'\
                  'services are a great source of linguistic knowledge'\
                  'for morphological, syntactic and semantic analysis'\
                  'of German both for traditional and Computational'\
                  'Linguistics (CL). Use this API to gain data on word'\
                  'frequencies, left and right neighbours, collocations and'\
                  'semantic similarity. Check it out if you are interested in'\
                  'Natural Language Processing (NLP) and Human Language'\
                  'Technology (HLT).'
  s.version = WLAPI::VERSION
  s.author = 'Andrei Beliankou'
  s.email = 'arbox@bu.chsta.be'
  s.homepage = 'http://bu.chsta.be/projects/wlapi/'
  s.add_runtime_dependency('savon', '~> 2.1')
  s.add_runtime_dependency('nori', '~> 2.4.0')
  s.add_development_dependency('rdoc', '~> 4.1')
  s.add_development_dependency('bundler', '~> 1.6')
  s.add_development_dependency('yard', '~> 0.8')
  s.add_development_dependency('rake', '~> 10.4')
  s.extra_rdoc_files = ['README.rdoc', 'LICENSE.rdoc', 'CHANGELOG.md']
  s.rdoc_options = ['-m', 'README.rdoc']
  s.has_rdoc = 'yard'
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>=1.8.5'
  s.files = FileList['lib/**/*.rb',
                     'README.rdoc',
                     'LICENSE.rdoc',
                     'CHANGELOG.md',
                     '.yardopts',
                     'test/**/*'].to_a
  s.test_files = FileList['test/**/*'].to_a
  s.licenses = 'MIT'
end
