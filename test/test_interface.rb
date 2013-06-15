require 'test/unit'
require 'test_helper'
require 'wlapi'

class TestInterface < Test::Unit::TestCase
  include TestHelper

  ONE_PAR = [:frequencies,
             :baseform,
             :domain]

  TWO_PAR = [:wordforms,
             :thesaurus,
             :synonyms,
             :sentences,
             :left_neighbours,
             :right_neighbours,
             :similarity,
             :experimental_synonyms,
             :ngrams,
             :ngram_references]

  THREE_PAR = [:right_collocation_finder,
               :left_collocation_finder,
               :cooccurrences,
               :cooccurrences_all,
               :intersection,
               :crossword]

  METHODS = ONE_PAR + TWO_PAR + THREE_PAR

  def setup
    @api = WLAPI::API.new
    @word = 'Stuhl'
  end

  def teardown
  end
  
  # Test constants.
  def test_constants
    assert(WLAPI::VERSION.is_a?(String))
    assert_equal(false, WLAPI::VERSION.empty?)
  end

  def test_availability_of_pulic_methods
    METHODS.each { |m| assert_respond_to(@api, m) }
  end

  def test_for_absent_arguments
    assert_raise(ArgumentError) do
      METHODS.each { |m| @api.send(m) }
    end
  end

  def test_for_redundant_arguments

    assert_raise(ArgumentError) do
      ONE_PAR.each { |m| @api.send(m, 'a', 2) }
    end

    assert_raise(ArgumentError) do
      TWO_PAR.each { |m| @api.send(m, 'a', 2, 3) }
    end
    

    assert_raise(ArgumentError) do
      THREE_PAR.each { |m| @api.send(m, 'a', 'a', 3, 4) }
    end    
  end

  def test_argument_semantics
    assert_raise(WLAPI::UserError) do
      ONE_PAR.each { |m| @api.send(m, 1) }
    end

    assert_raise(WLAPI::UserError) do
      TWO_PAR.each { |m| @api.send(m, 'Haus', [:a]) }
    end

    assert_raise(WLAPI::UserError) do
      THREE_PAR.each { |m| @api.send(m, 3, 3.5, 'a') }
    end
  end

end
