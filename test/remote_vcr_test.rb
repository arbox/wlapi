# coding: utf-8
require 'yaml'
require 'test/unit'
require 'test_helper.rb'
require 'vcr'
require 'wlapi'

VCR.configure do |c|
  c.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  c.hook_into :webmock
end

class TestApi < Test::Unit::TestCase
  include TestHelper

  credentials = YAML.load_file('SENSITIVE')['credentials']
  USER = credentials['user']
  PASS = credentials['pass']

  def setup
    @api = WLAPI::API.new(USER, PASS)
  end

  def teardown
  end 

  # VCR Test
  def test_test
    VCR.use_cassette('vcr_test') do
      expectation = ["Buch",
                     "Bücher",
                     "Büchern",
                     "Buches",
                     "Buchs",
                     "Bucher"]
      execute(expectation, :wordforms, 'Buch')
    end
  end
end
