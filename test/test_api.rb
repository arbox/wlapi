# -*- coding: utf-8 -*-
require 'test/unit'
require 'wlapi'


class TestApi < Test::Unit::TestCase

  METHODS = [:baseform,
             :domain,
             :wordforms,
             :thesaurus,
             :synonyms,
             :sentences,
             :left_neighbours,
             :right_neighbours,
             :similarity,
             :experimental_synonyms,
             :right_collocation_finder,
             :left_collocation_finder,
             :cooccurrences,
             :cooccurrences_all,
             :intersection,
             :frequencies
            ]
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

  def test_availability_of_pulic_methods
    METHODS.each { |m| assert_respond_to(@api, m) }
  end

  def test_for_absent_arguments
    assert_raise(ArgumentError) do
      METHODS.each { |m| @api.send(m) }
    end
  end

  def test_for_redundant_arguments
    one_par = [:frequencies,
               :baseform,
               :domain
              ]
    assert_raise(ArgumentError) do
      one_par.each { |m| @api.send(m, 1, 2) }
    end

    two_par = [:wordforms,
               :thesaurus,
               :synonyms,
               :sentences,
               :left_neighbours,
               :right_neighbours,
               :similarity,
               :experimental_synonyms
              ]
    assert_raise(ArgumentError) do
      two_par.each { |m| @api.send(m, 1, 2, 3) }
    end
    
    three_par = [:right_collocation_finder,
                 :left_collocation_finder,
                 :cooccurrences,
                 :cooccurrences_all,
                 :intersection
                ]
    assert_raise(ArgumentError) do
      three_par.each { |m| @api.send(m, 1, 2, 3, 4) }
    end    
  end

  # one parameter
  def test_frequencies
    response = @api.frequencies('Haus')
    check_response(response)

    assert_equal(2, response.size)
    assert_match(/\d+/, response[0])
    assert_match(/\d+/, response[1])
    assert_equal(["122072", "7"], response)
  end

  def test_baseform
    response = @api.baseform('Autos')
    check_response(response)

    assert_equal(2, response.size)
    assert_match(/\w+/, response[0])
    assert_match(/[AVN]/, response[1])
    assert_equal(["Auto", "N"], response)
  end

  def test_domain
    response = @api.domain('Buch')
    check_response(response)

    expected_response = ["Sprachwissenschaft",
                         "Nachname",
                         "Stadt",
                         "Buchkunde/Buchhandel",
                         "Motive",
                         "Literarische/Motive/Stoffe/Gestalten",
                         "Buchkunde/Buchhandel",
                         "Papierherstellung/Graphische/Technik",
                         "Buchkunde/Buchhandel",
                         "Bücher",
                         "Ort in D"
                        ]
    assert_equal(expected_response, response)
    # We cannot predict the minimal structure of the response.
  end
  
  # two parameters
  def test_wordforms
    response = @api.wordforms('Buch')
    check_response(response)

    expected_response = ["Buch",
                         "Bücher",
                         "Büchern",
                         "Buches",
                         "Buchs",
                         "Bucher"
                        ]
    assert_equal(expected_response, response)
  end

  def test_thesaurus
    response = @api.thesaurus('Buch')
    check_response(response)

    expected_response = ["Buch", "Titel", "Werk", "Zeitung", "Band",
                         "Literatur", "Zeitschrift", "Bruch", "Lektüre",
                         "Schrift"]
    assert_equal(expected_response, response)
  end

  def test_synonyms
    response = @api.synonyms('Brot')
    check_response(response)

    expected_response = ["Laib", "Brotlaib", "Laib", "Schnitte", "Stulle"]
    assert_equal(expected_response, response)
  end

  def test_sentences
    response = @api.sentences('Klasse', 1)
    check_response(response)
    expected_response = ["40829928",
                         "Bei den Grünen war ich wohl im Urteil der politisch korrekten Klasse bei den Richtigen, auch wenn ich in ihren Augen das Falsche sagte."] 
    assert_equal(expected_response, response)
  end

  def test_left_neighbours
    response = @api.left_neighbours('Stuhl', 2)
    check_response(response)

    expected_response = ["elektrischen", "Stuhl", "626",
                         "seinem", "Stuhl", "592"]
    assert_equal(expected_response, response)
  end

  def test_right_neighbours
    response = @api.right_neighbours('Stuhl', 2)
    check_response(response)

    expected_response = ["Stuhl", "räumen", "189",
                         "Stuhl", "hin und her", "130"]
    assert_equal(expected_response, response)
  end

  def test_similarity
    response = @api.similarity(@word)
    check_response(response)

  end

  def test_experimental_synonyms
    response = @api.experimental_synonyms(@word)
    check_response(response)

  end
  
  # three parameters
  def test_right_collocation_finder
    response = @api.right_collocation_finder(@word, 'V')
    check_response(response)

  end

  def test_left_collocation_finder
    response = @api.left_collocation_finder(@word, 'A')
    check_response(response)

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

################## HELPER METHODS ###############################################
  def check_response(response)
    assert_not_nil(response)
    assert_instance_of(Array, response)
    assert(response.any?)
  end
end
