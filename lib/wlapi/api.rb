# -*- encoding: utf-8 -*-
# 2010-2014, Andrei Beliankou
# @author Andrei Beliankou

# :title: Ruby based API for Wortschatz Leipzig web services
# :main: README.rdoc

require 'savon'
require 'wlapi/error'

# REXML is fast enough for our task.
# But we consider using Nokogiri since Savon depends on it
# and we won't introduce additional dependencies.
require 'rexml/document'


module WLAPI

  # This class represents an interface to the linguistic web services
  # provided by the University of Leipzig.
  #
  # See the project 'Wortschatz Leipzig' for more details.
  class API
    include REXML

    # SOAP Services Endpoint.
    ENDPOINT = 'http://wortschatz.uni-leipzig.de/axis/services'

    # The list of accessible services, the MARSService is excluded due
    # to its internal authorization.
    SERVICES = [
      :Baseform, :Cooccurrences, :CooccurrencesAll,
      :ExperimentalSynonyms, :Frequencies,
      :Kookurrenzschnitt, :Kreuzwortraetsel,
      :LeftCollocationFinder, :LeftNeighbours, :NGrams,
      :NGramReferences, :RightCollocationFinder,
      :RightNeighbours, :Sachgebiet, :Sentences,
      :Similarity, :Synonyms, :Thesaurus, :Wordforms
    ]

    # At the creation point clients for all services are being instantiated.
    # You can also set the login and the password (it defaults to 'anonymous').
    #   api = WLAPI::API.new
    def initialize(login = 'anonymous', pass = 'anonymous')

      # This hash contains the URLs to the single services.
      services = {}

      SERVICES.each { |service| services[service] = "#{ENDPOINT}/#{service}"}

      # cl short for client.
      # Dynamically create all the clients and set access credentials.
      # It can be a very bad idea to instantiate all the clients at once,
      # we should investigate the typical user behaviour.
      # If only one service is used in the separate session => rewrite the class!
      services.each do |key, val|
        cl_name = "@cl_#{key}"

        options = {:wsdl => val + '?wsdl',
                   :namespaces => {'xmlns:dat' => 'http://datatypes.webservice.wortschatz.uni_leipzig.de',
                                   'xmlns:urn' => val},
                   :basic_auth => ['anonymous', 'anonymous'],
                   :log => $DEBUG
                  }

        client = Savon.client(options)

        eval("#{cl_name} = client")
      end

      # Savon creates very verbose logs, switching off.
      HTTPI.log = false unless $DEBUG
    end

    # Main methods to access different services.
    #
    # You can define the limit for the result set, it defaults to 10.
    # If you want to get all the results, you should provide a number,
    # which would be greater than the result set since we cannot
    # predict how many answers the server will give us.
    ############################################################################

    ## One parameter methods.
    ############################################################################

    # Returns the frequency and frequency class of the input word.
    # Frequency class is computed in relation to the most frequent word
    # in the corpus. The higher the class, the rarer the word:
    #   api.frequencies("Autos") => ["40614", "9"]
    # @return [Array] a list
    def frequencies(word)
      check_params(word)

      arg1 = ['Wort', word]
      answer = query(@cl_Frequencies, arg1)

      get_answer(answer)
    end

    # Gets the baseform (whatever it is :), not lemma).
    # Returns the lemmatized (base) form of the input word
    # and the POS tag in an array:
    #   api.baseform("Auto") => ["Auto", "N"]
    # @return [Array] a list
    def baseform(word)
      check_params(word)

      arg1 = ['Wort', word]
      answer = query(@cl_Baseform, arg1)

      get_answer(answer)
    end

    # Returns categories for a given input word as an array:
    #   api.domain("Michael") => ["Vorname", "Nachname", "Männername"]
    #--
    # Is it a good name? all names are in English, but here..
    # let's call it domain, not sachgebiet
    def domain(word)
      check_params(word)

      arg1 = ['Wort', word]
      answer = query(@cl_Sachgebiet, arg1)

      get_answer(answer)
    end

    ## Two parameter methods.
    ############################################################################

    # Returns all other word forms of the same lemma for a given word form.
    #   api.wordforms("Auto") => ["Auto", "Autos"]
    # @return [Array] a list
    def wordforms(word, limit = 10)
      check_params(word, limit)

      # note, it is the only service which requires 'Word', not 'Wort'
      arg1 = ['Word', word]
      arg2 = ['Limit', limit]
      answer = query(@cl_Wordforms, arg1, arg2)

      get_answer(answer)
    end

    # As the Synonyms service returns synonyms of the given input word.
    # However, this first builds a lemma of the input word
    # and thus returns more synonyms:
    #   api.thesaurus("Auto") => ["Auto", "Bahn", "Wagen", "Zug", "Schiff", ...]
    # @return [Array] a list
    def thesaurus(word, limit = 10)
      check_params(word, limit)

      arg1 = ['Wort', word]
      arg2 = ['Limit', limit]
      answer = query(@cl_Thesaurus, arg1, arg2)

      get_answer(answer)
    end

    # This method searches for synonyms.
    # Returns synonyms of the input word. In other words, this is a thesaurus.
    #   api.synonyms("Auto") => ["Kraftwagen", "Automobil", "Benzinkutsche", ...]
    # @return [Array] a list
    def synonyms(word, limit = 10)
      check_params(word, limit)

      arg1 = ['Wort', word]
      arg2 = ['Limit', limit]
      answer = query(@cl_Synonyms, arg1, arg2)

      # Synonym service provides multiple values, so we take only odd.
      get_answer(answer, '[position() mod 2 = 1 ]')
    end

    # Returns sample sentences containing the input word.
    # The return value is an array:
    #   api.sentences("Auto") => ["40808144", "Zweitens der freche,
    #   frische Klang der Hupe
    #   und drittens die hinreißend gestylten 16-Zoll-Felgen,
    #   die es leider nur für dieses Auto gibt.", ...]
    #--
    # @todo ok, but results should be filtered
    def sentences(word, limit = 10)
      check_params(word, limit)

      arg1 = ['Wort', word]
      arg2 = ['Limit', limit]
      answer = query(@cl_Sentences, arg1, arg2)

      get_answer(answer)
    end

    # For a given input word, returns statistically significant left neighbours
    # (words co-occurring immediately to the left of the input word).
    #   api.left_neighbours("Auto") => ["geparktes", "Auto", "561", ...]
    #--
    # @todo ok, but results should be filtered
    def left_neighbours(word, limit = 10)
      check_params(word, limit)

      arg1 = ['Wort', word]
      arg2 = ['Limit', limit]
      answer = query(@cl_LeftNeighbours, arg1, arg2)

      get_answer(answer)
    end

    # For a given input word, returns statistically significant right neighbours
    # (words co-occurring immediately to the right of the input word).
    #   api.right_neighbours("Auto") => ["Auto", "erfaßt", "575", ...]
    #--
    # @todo ok, but results should be filtered
    def right_neighbours(word, limit = 10)
      check_params(word, limit)

      arg1 = ['Wort', word]
      arg2 = ['Limit', limit]
      answer = query(@cl_RightNeighbours, arg1, arg2)

      get_answer(answer)
    end


    # Returns automatically computed contextually similar words
    # of the input word.
    # Such similar words may be antonyms, hyperonyms, synonyms,
    # cohyponyms or other.
    # Note that due to the huge amount of data any query to this services
    # may take a long time.
    #   api.similarity("Auto") => ["Auto", "Wagen", "26", ...]
    def similarity(word, limit = 10)
      check_params(word, limit)

      arg1 = ['Wort', word]
      arg2 = ['Limit', limit]
      answer = query(@cl_Similarity, arg1, arg2)

      get_answer(answer)
    end

    # This service delivers an experimental synonyms request for internal tests.
    #--
    # don't know, if we have to include this service...
    def experimental_synonyms(word, limit = 10)
      check_params(word, limit)

      arg1 = ['Wort', word]
      arg2 = ['Limit', limit]
      answer = query(@cl_ExperimentalSynonyms, arg1, arg2)

      get_answer(answer)
    end

    # @todo Define the syntax for the pattern, fix the corpus.
    def ngrams(pattern, limit = 10)
      arg1 = ['Pattern', pattern]
      arg2 = ['Limit', limit]
      answer = query(@cl_NGrams, arg1, arg2)
    # raise(NotImplementedError, 'This method will be implemented in the next release.')
    end

    # @todo Define the syntax for the pattern, fix the corpus.
    def ngram_references(pattern, limit = 10)
      arg1 = ['Pattern', pattern]
      arg2 = ['Limit', limit]
      answer = query(@cl_NGramReferences, arg1, arg2)
    # raise(NotImplementedError, 'This method will be implemented in the next release.')
    end

    ## Three parameter methods.
    ############################################################################

    # Attempts to find linguistic collocations that occur to the right
    # of the given input word.
    # The parameter 'Wortart' accepts four values 'A, V, N, S'
    # which stand for adjective, verb, noun and stopword respectively.
    # The parameter restricts the type of words found.
    # It returns an array:
    #   api.right_collocation_finder("Auto", "V", 10) =>
    #   ["Auto", "abfackeln", "V", ...]
    def right_collocation_finder(word, pos, limit = 10)
      check_params(word, pos, limit)

      arg1 = ['Wort', word]
      arg2 = ['Wortart', pos]
      arg3 = ['Limit', limit]
      answer = query(@cl_RightCollocationFinder, arg1, arg2, arg3)

      get_answer(answer)
    end

    # Attempts to find linguistic collocations that occur to the left
    # of the given input word.
    # The parameter 'Wortart' accepts four values 'A, V, N, S'
    # which stand for adjective, verb, noun and stopword respectively.
    # The parameter restricts the type of words found.
    # It returns an array:
    #   api.left_collocation_finder("Stuhl", "A", 10) =>
    #   ["apostolisch", "A", "Stuhl", ...]
    def left_collocation_finder(word, pos, limit = 10)
      check_params(word, pos, limit)

      arg1 = ['Wort', word]
      arg2 = ['Wortart', pos]
      arg3 = ['Limit', limit]
      answer = query(@cl_LeftCollocationFinder, arg1, arg2, arg3)

      get_answer(answer)
    end

    # Returns statistically significant co-occurrences of the input word.
    def cooccurrences(word, sign, limit = 10)
      check_params(word, sign, limit)

      arg1 = ['Wort', word]
      arg2 = ['Mindestsignifikanz', sign]
      arg3 = ['Limit', limit]
      answer = query(@cl_Cooccurrences, arg1, arg2, arg3)

      get_answer(answer)
    end

    # Returns statistically significant co-occurrences of the input word.
    # However, it searches in the unrestricted version of the co-occurrences
    # table as in the Cooccurrences services,
    # which means significantly longer wait times.
    def cooccurrences_all(word, sign, limit = 10)
      check_params(word, sign, limit)

      arg1 = ['Wort', word]
      arg2 = ['Mindestsignifikanz', sign]
      arg3 = ['Limit', limit]
      answer = query(@cl_CooccurrencesAll, arg1, arg2, arg3)

      get_answer(answer)
    end

    # Returns the intersection of the co-occurrences of the two given words.
    # The result set is ordered according to the sum of the significances
    # in descending order. Note that due to the join involved,
    # this make take some time.
    #--
    # let's call it intersection, not kookurrenzschnitt
    # is being used INTERN, we need additional credentials
    def intersection(word1, word2, limit = 10)
      check_params(word1, word2, limit)

      arg1 = ['Wort 1', word1]
      arg2 = ['Wort 2', word2]
      arg3 = ['Limit', limit]
      answer = query(@cl_Kookurrenzschnitt, arg1, arg2, arg3)

      get_answer(answer)
    end

    # Attempts to find suitable words given a pattern as word parameter,
    # a word length and the number of words to find at max (limit),
    # e.g. <tt>API#crossword('%uto', 4)</tt> would return find 24 results and
    # return them as an array: <tt>[Auto, Auto, ...]</tt>:
    #   api.crossword('%uto') => ["Auto", "Auto", ...]
    # SQL like syntax is used for pattern (<tt>%</tt> for an arbitrary string,
    # <tt>_</tt> for a single character).
    #
    # Note: Umlaute will count as one character
    #
    #--
    # Let's keep all public method names in English:
    # kreuzwortraetsel => crossword.
    def crossword(word, word_length, limit = 10)
      check_params(word, word_length, limit)

      arg1 = ['Wort', word ]
      arg2 = ['Wortlaenge', word_length]
      arg3 = ['Limit', limit]
      answer = query(@cl_Kreuzwortraetsel, arg1, arg2, arg3)

      get_answer(answer)
    end

    private

    # Main query method, it invokes the soap engine.
    # It combines all the data to one SOAP request and gets the answer.
    # <args> contains an array [[key1, value1], [key2, value2], [key3, value3]]
    # with keys and values for the soap query.
    def query(cl, *args)
      # WSDL is disabled since calling the server for wsdl can last too long.
      v = []
      body = {
        'urn:objRequestParameters' => {
          'urn:corpus' => 'de',
          'urn:parameters' => {
            'urn:dataVectors' => v
          }
        }
      }

      # _args_ is an Array of arrays with keys and values
      # Setting the first argument (usually 'Wort').
      # Setting the second argument (usually 'Limit').
      # Setting the third argument (no common value).
      args.each do |key, val|
        v << {'dat:dataRow' => [key, val]}
      end

      begin
        resp = cl.call(:execute, {:message => body})
      rescue => e
        raise(WLAPI::ExternalError, e)
      end

      doc = Document.new(resp.to_xml)
      warn(doc) if $DEBUG

      doc
    end

    # This method extracts valuable data from the XML structure
    # of the soap response. It returns an array with extracted xml text nodes
    # or nil, if the service provided no answer.
    def get_answer(doc, mod='')
      result = []
      # The path seems to be weird, because the namespaces change incrementally
      # in the output, so I don't want to treat it here.
      # A modifier needed because synonyms service provides duplicate values.
      XPath.each(doc, "//result/*/*#{mod}") do |el|
        warn(el.text) if $DEBUG
        result << el.text
      end

      result.any? ? result : nil
    end

    def check_params(*args)
      m = caller(1).first.match(/^.+`(.*)'$/)[1]
      num_of_args = self.method(m.to_sym).arity
      messages = []

      # Arity can be negativ => .abs.
      case num_of_args.abs
      when 1
        messages << msg(args[0], m, 'String') unless args[0].is_a?(String)
      when 2
        messages << msg(args[0], m, 'String') unless args[0].is_a?(String)
        messages << msg(args[1], m, 'Numeric') unless args[1].is_a?(Fixnum)
      when 3
        messages << msg(args[0], m, 'String') unless args[0].is_a?(String)
        unless args[1].is_a?(String) || args[1].is_a?(Fixnum)
          messages << msg(args[1], m, 'String or Numeric')
        end
        messages << msg(args[2], m, 'Numeric') unless args[2].is_a?(Fixnum)
      end

      if messages.any?
        fail WLAPI::UserError, messages.join("\n")
      end
    end

    def msg(arg, meth, cls)
      "Argument <#{arg}> for the method <#{meth}> should be a <#{cls}>, "\
      "not <#{arg.class}>!"
    end
  end # class API
end # module WLAPI
