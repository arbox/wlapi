# -*- coding: utf-8 -*-
require 'test/unit'
require 'wlapi'


class TestApi < Test::Unit::TestCase

  ONE_PAR = [:frequencies,
             :baseform,
             :domain
            ]

  TWO_PAR = [:wordforms,
             :thesaurus,
             :synonyms,
             :sentences,
             :left_neighbours,
             :right_neighbours,
             :similarity,
             :experimental_synonyms,
             :ngrams,
             :ngram_references
            ]

  THREE_PAR = [:right_collocation_finder,
               :left_collocation_finder,
               :cooccurrences,
               :cooccurrences_all,
               :intersection,
               :crossword
              ]

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
 
  # One parameter.
  def test_frequencies
    expectation = ['122072', '7']

    response = execute(expectation, :frequencies, 'Haus')

    assert_equal(2, response.size)
    assert_match(/\d+/, response[0])
    assert_match(/\d+/, response[1])
  end

  def test_baseform
    expectation = ['Auto', 'N']
    
    response = execute(expectation, :baseform, 'Autos')

    assert_equal(2, response.size)
    assert_match(/\w+/, response[0])
    assert_match(/[AVN]/, response[1])
  end

  def test_domain
    expectation = ["Sprachwissenschaft",
                   "Nachname",
                   "Stadt",
                   "Buchkunde/Buchhandel",
                   "Motive",
                   "Literarische/Motive/Stoffe/Gestalten",
                   "Buchkunde/Buchhandel",
                   "Papierherstellung/Graphische/Technik",
                   "Buchkunde/Buchhandel",
                   "Bücher",
                   "Ort in D"]
    execute(expectation, :domain, 'Buch')
  end
  
  # two parameters
  def test_wordforms
    expectation = ["Buch",
                   "Bücher",
                   "Büchern",
                   "Buches",
                   "Buchs",
                   "Bucher"]
    execute(expectation, :wordforms, 'Buch')
  end

  def test_thesaurus
    expectation = ["Buch", "Titel", "Werk", "Zeitung", "Band",
                   "Literatur", "Zeitschrift", "Bruch", "Lektüre",
                   "Schrift"]
    execute(expectation, :thesaurus, 'Buch')
  end

  def test_synonyms
    expectation = ["Laib", "Brotlaib", "Laib", "Schnitte", "Stulle"]
    execute(expectation, :synonyms, 'Brot')
  end

  def test_sentences
    expectation = ["40829928", "Bei den Grünen war ich wohl im Urteil der politisch korrekten Klasse bei den Richtigen, auch wenn ich in ihren Augen das Falsche sagte."] 
    execute(expectation, :sentences, 'Klasse', 1)
  end

  def test_left_neighbours
    expectation = ["elektrischen", "Stuhl", "626", "seinem", "Stuhl", "592"]
    execute(expectation, :left_neighbours, 'Stuhl', 2)
  end

  def test_right_neighbours
    expectation = ["Stuhl", "räumen", "189", "Stuhl", "hin und her", "130"]
    execute(expectation, :right_neighbours, 'Stuhl', 2)
  end

  def test_similarity
    expectation = ["Stuhl", "Sessel", "26",
                   "Stuhl", "Lehnstuhl", "24",
                   "Stuhl", "Sofa", "21"] 
    execute(expectation, :similarity, 'Stuhl', 3)
  end

  def test_experimental_synonyms
    expectation = ["Einrichtungsgegenstand", "v",
                   "Bett", "v",
                   "Lampe", "v",
                   "Tisch", "v",
                   "Schrank", "v",
                   "Teppich", "v",
                   "Gebrauchsmöbel", "v",
                   "Möbelstück", "v",
                   "Bank", "v",
                   "Bord", "v"]
    execute(expectation, :experimental_synonyms, 'Stuhl')
  end
  
  # three parameters
  def test_right_collocation_finder
    expectation = ["Stuhl", "aufmöbeln", "V",
                   "Stuhl", "aufreihen", "V",
                   "Stuhl", "aufspringen", "V"]
    execute(expectation, :right_collocation_finder, 'Stuhl', 'V', 3)
  end

  def test_left_collocation_finder
    expectation = ["Hl", "A", "Stuhl",
                   "abwaschbar", "A", "Stuhl",
                   "alle", "A", "Stuhl"]
    execute(expectation, :left_collocation_finder, 'Stuhl', 'A', 3)
  end

  def test_cooccurrences
    expectation = ["Haus", "das", "11747"]
    execute(expectation, :cooccurrences, 'Haus', 10000)    
  end

  def test_cooccurrences_all
    begin
      execute(['Expected'], :cooccurrences_all, 'Haus', 10000)
    rescue WLAPI::ExternalError => e
      assert_match(/You're not allowed to access this service./, e.message)
    end
    # Not possible to test without access credential.
  end

  def test_intersection
    begin
      execute(['Expected'], :intersection, 'Haus', 'Brot', 1)
    rescue WLAPI::ExternalError => e
      assert_match(/You're not allowed to access this service./, e.message)
    end
    # Not possible to test without access credentials.
  end
  
  def test_crossword
    expectation = ['word'] * 24
    response = execute(expectation, :crossword, '%uto', 4, 200)
    assert(response.length == 24)
  end
 
################## HELPER METHODS ###############################################
  def execute(expectation, method, *args)
    begin
      result = @api.send(method, *args)
    rescue => error
      if error.message =~ /(Server shutdown in progress)|(404)/i
        result = expectation
      else
        raise        
      end
    end

    check_response(result)
    assert_equal(expectation, result)

    result
  end

  def check_input(*args)
  end

  
  def check_response(response)
    assert_not_nil(response)
    assert_instance_of(Array, response)
    assert(response.any?)
  end
end
