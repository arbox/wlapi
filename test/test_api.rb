# -*- coding: utf-8 -*-
require 'test/unit'
require 'fakeweb'
require 'wlapi'


class TestApi < Test::Unit::TestCase

  def setup
    @api = WLAPI::API.new
    @word = 'Stuhl'
  end

  def teardown
  end
  
  # test constants
  def test_constants
    assert(WLAPI::VERSION.is_a?(String))
    assert_equal(false, WLAPI::VERSION.empty?)
  end
=begin
  # It should generate a valid soap request for some input.
  def test_soap_generation
    file = 'test/data/soap_request.txt'
    soap = File.read(file)
    
    url = 'http://wortschatz.uni-leipzig.de/axis/services/Thesaurus'
    FakeWeb.register_uri(:post, url, :response => http_resp)

    actual_api_answer = query.get
    assert_instance_of(String, actual_api_answer, 'Not String!')
    assert_equal(expected_api_answer, actual_api_answer)
  end
=end
  # one parameter
  def test_frequencies
    assert_respond_to(@api, :frequencies)
    assert_raise(ArgumentError) do
      @api.frequencies(@word, 5)
    end
    assert_raise(ArgumentError) do
      @api.frequencies
    end
    response = @api.frequencies(@word)
    assert_not_nil(response)
    assert_instance_of(Array, response)
    assert(!response.empty?)
    assert_equal(2, response.size)
    assert_match(/\d+/, response[0])
    assert_match(/\d+/, response[1])
  end

  def test_baseform
    assert_respond_to(@api, :baseform)
    assert_raise(ArgumentError) do
      @api.baseform(@word, 5)
    end
    assert_raise(ArgumentError) do
      @api.baseform
    end
    response = @api.baseform(@word)
    assert_not_nil(response)
    assert_instance_of(Array, response)
    assert(!response.empty?)
    assert_equal(2, response.size)
    assert_match(/\w+/, response[0])
    assert_match(/[AVN]/, response[1])
  end

  def test_domain
    assert_respond_to(@api, :domain)
    assert_raise(ArgumentError) do
      @api.domain(@word, 5)
    end
    assert_raise(ArgumentError) do
      @api.domain
    end
    response = @api.domain(@word)
    assert_not_nil(response)
    assert_instance_of(Array, response)
    assert(!response.empty?)
    # we cannot predict the minimal structure of the response
  end
  
  # two parameters
  def test_wordforms
    assert_respond_to(@api, :wordforms)
    assert_raise(ArgumentError) do
      @api.wordforms
    end
    assert_raise(ArgumentError) do
      @api.wordforms(1, 2, 3)
    end
    response = @api.wordforms(@word)
    assert_not_nil(response)
    assert_instance_of(Array, response)
    assert(!response.empty?)
  end

  def test_thesaurus
    assert_respond_to(@api, :thesaurus)
    assert_raise(ArgumentError) do
      @api.thesaurus
    end
    assert_raise(ArgumentError) do
      @api.thesaurus(1, 2, 3)
    end
    response = @api.thesaurus(@word)
    assert_not_nil(response)
    assert_instance_of(Array, response)
    assert(!response.empty?)
  end

  def test_synonyms
    assert_respond_to(@api, :synonyms)
    assert_raise(ArgumentError) do
      @api.synonyms
    end
    assert_raise(ArgumentError) do
      @api.synonyms(1, 2, 3)
    end
    response = @api.synonyms(@word)
    assert_not_nil(response)
    assert_instance_of(Array, response)
    assert(!response.empty?)
  end

  def test_sentences
    assert_respond_to(@api, :sentences)
    assert_raise(ArgumentError) do
      @api.sentences
    end
    assert_raise(ArgumentError) do
      @api.sentences(1, 2, 3)
    end
    response = @api.sentences(@word)
    assert_not_nil(response)
    assert_instance_of(Array, response)
    assert(!response.empty?)
  end

  def test_left_neighbours
    assert_respond_to(@api, :left_neighbours)
    assert_raise(ArgumentError) do
      @api.left_neighbours
    end
    assert_raise(ArgumentError) do
      @api.left_neighbours(1, 2, 3)
    end
    response = @api.left_neighbours(@word)
    assert_not_nil(response)
    assert_instance_of(Array, response)
    assert(!response.empty?)
  end

  def test_right_neighbours
    assert_respond_to(@api, :right_neighbours)
    assert_raise(ArgumentError) do
      @api.right_neighbours
    end
    assert_raise(ArgumentError) do
      @api.right_neighbours(1, 2, 3)
    end
    response = @api.right_neighbours(@word)
    assert_not_nil(response)
    assert_instance_of(Array, response)
    assert(!response.empty?)
  end

  def test_similarity
    assert_respond_to(@api, :similarity)
    assert_raise(ArgumentError) do
      @api.similarity
    end
    assert_raise(ArgumentError) do
      @api.similarity(1, 2, 3)
    end
    response = @api.similarity(@word)
    assert_not_nil(response)
    assert_instance_of(Array, response)
    assert(!response.empty?)
  end

  def test_experimental_synonyms
    assert_respond_to(@api, :experimental_synonyms)
    assert_raise(ArgumentError) do
      @api.experimental_synonyms
    end
    assert_raise(ArgumentError) do
      @api.experimental_synonyms(1, 2, 3)
    end
    response = @api.experimental_synonyms(@word)
    assert_not_nil(response)
    assert_instance_of(Array, response)
    assert(!response.empty?)
  end
  
  # three parameters
  def test_right_collocation_finder
    assert_respond_to(@api, :right_collocation_finder)
        assert_raise(ArgumentError) do
      @api.right_collocation_finder
    end
    assert_raise(ArgumentError) do
      @api.right_collocation_finder(1, 2, 3, 4)
    end
    response = @api.right_collocation_finder(@word, 'V')
    assert_not_nil(response)
    assert_instance_of(Array, response)
    assert(!response.empty?)
  end

  def test_left_collocation_finder
    assert_respond_to(@api, :left_collocation_finder)
    assert_raise(ArgumentError) do
      @api.left_collocation_finder
    end
    assert_raise(ArgumentError) do
      @api.left_collocation_finder(1, 2, 3, 4)
    end
    response = @api.left_collocation_finder(@word, 'A')
    assert_not_nil(response)
    assert_instance_of(Array, response)
    assert(!response.empty?)
  end

  def test_cooccurrences
    assert_raise(NotImplementedError) do
      @api.cooccurrences(@word, 1, 10)
    end
  end

  def test_cooccurrences_all
    assert_raise(NotImplementedError) do
      @api.cooccurrences_all(@word, 1, 10)
    end
  end

  def test_intersection
    assert_raise(NotImplementedError) do
      @api.intersection(@word, @word, 10)
    end
  end
end
