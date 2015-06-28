# coding: utf-8
require 'yaml'
require 'minitest/autorun'
require 'test_helper.rb'
require 'vcr'
require 'wlapi'

class TestApi < Minitest::Test
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
    expectation = ["Buch",
                   "Bücher",
                   "Büchern",
                   "Buches",
                   "Buchs",
                   "Bucher"]
    execute(expectation, :wordforms, 'Buch')
  end
end
