# -*- coding: utf-8 -*-
# 2010-, Andrei Beliankou

# :title: Ruby based API for Wortschatz Leipzig web services
# :main: README

require 'savon'

# REXML is fast enough for our task.
require 'rexml/document'
include REXML

# Top level namespace wrapper for WLAPI
module WLAPI

  # This class represents an interface to the linguistic web services
  # provided by the University of Leipzig.
  #
  # See the project 'Wortschatz Leipzig' for more details.
  class API
    
    # At the creation point clients for all services are being instantiated.
    # You can also set the login and the password (it defaults to 'anonymous').
    #   api = WLAPI::API.new
    def initialize(login = 'anonymous', pass = 'anonymous')

      # This hash contains the URLs to the single services.
      endpoint = 'http://wortschatz.uni-leipzig.de/axis/services'
      @services = {
        :Thesaurus => "#{endpoint}/Thesaurus",
        :Baseform => "#{endpoint}/Baseform",
        :Similarity => "#{endpoint}/Similarity",
        :Synonyms => "#{endpoint}/Synonyms",
        :Sachgebiet => "#{endpoint}/Sachgebiet",
        :Frequencies => "#{endpoint}/Frequencies",
        :Kookurrenzschnitt => "#{endpoint}/Kookkurrenzschnitt",
        :ExperimentalSynonyms => "#{endpoint}/ExperimentalSynonyms",
        :RightCollocationFinder => "#{endpoint}/RightCollocationFinder",
        :LeftCollocationFinder => "#{endpoint}/LeftCollocationFinder",
        :Wordforms => "#{endpoint}/Wordforms",
        :CooccurrencesAll => "#{endpoint}/CooccurrencesAll",
        :LeftNeighbours => "#{endpoint}/LeftNeighbours",
        :RightNeighbours => "#{endpoint}/RightNeighbours",
        :Sentences => "#{endpoint}/Sentences",
        :Cooccurrences => "#{endpoint}/Cooccurrences"
        # no MARSService and Kreuzwortrraetsel
      }
      
      # cl short for client.
      # Dynamically create all the clients and set access credentials.
      # It can be a very bad idea to instantiate all the clients at once,
      # we should investigate the typical user behaviour.
      # If only one service is used in the separate session => rewrite the class!
      @services.each do |key, val|
        cl_name = '@cl_' + key.to_s
        eval("#{cl_name} = Savon::Client.new { |wsdl| wsdl.endpoint = val}")
        eval("#{cl_name}.wsdl.namespace = val")
        eval("#{cl_name}.http.auth.basic(login, pass)")
      end
      
      # Savon creates very verbose logs, switching off.
      Savon.configure do |config|
        config.log = false unless $DEBUG
      end
      HTTPI.log = false unless $DEBUG
    end
    
    # Main methods to access different services.
    #
    # You can define the limit for the result set, it defaults to 10.
    # If you want to get all the results, you should provide a number,
    # which would be greater than the result set since we cannot
    # predict how many answers the server will give us.
    #############################################################################
    
    ## One parameter methods.
    #############################################################################
    
    # Returns the frequency and frequency class of the input word.
    # Frequency class is computed in relation to the most frequent word
    # in the corpus. The higher the class, the rarer the word:
    #   api.frequencies("Autos") => ["40614", "9"]
    def frequencies(word)
      arg1 = ['Wort', word]
      answer = query(@cl_Frequencies, arg1)

      get_answer(answer)
    end
    
    # Gets the baseform (whatever it is :) not lemma).
    # Returns the lemmatized (base) form of the input word
    # and the POS tag in an array:
    #   api.baseform("Auto") => ["Auto", "N"]
    def baseform(word)
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
      arg1 = ['Wort', word]
      answer = query(@cl_Sachgebiet, arg1)
      
      get_answer(answer)
    end
    
    ## Two parameter methods.
    #############################################################################
    
    # Returns all other word forms of the same lemma for a given word form.
    #   api.wordforms("Auto") => ["Auto", "Autos"]
    def wordforms(word, limit = 10)
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
    def thesaurus(word, limit = 10)
      arg1 = ['Wort', word]
      arg2 = ['Limit', limit]
      answer = query(@cl_Thesaurus, arg1, arg2)
      
      get_answer(answer)
    end
    
    # This method searches for synonyms.
    # Returns synonyms of the input word. In other words, this is a thesaurus.
    #   api.synonyms("Auto") => ["Kraftwagen", "Automobil", "Benzinkutsche", ...]
    def synonyms(word, limit = 10)
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
    # ok, but results should be filtered
    def sentences(word, limit = 10)
      arg1 = ['Wort', word]
      arg2 = ['Limit', limit]
      answer = query(@cl_Sentences, arg1, arg2)
      
      get_answer(answer)
    end
    
    # For a given input word, returns statistically significant left neighbours
    # (words co-occurring immediately to the left of the input word).
    #   api.left_neighbours("Auto") => ["geparktes", "Auto", "561", ...]
    #--
    # ok, but results should be filtered
    def left_neighbours(word, limit = 10)
      arg1 = ['Wort', word]
      arg2 = ['Limit', limit]
      answer = query(@cl_LeftNeighbours, arg1, arg2)
      
      get_answer(answer)
    end
    
    # For a given input word, returns statistically significant right neighbours
    # (words co-occurring immediately to the right of the input word).
    #   api.right_neighbours("Auto") => ["Auto", "erfaßt", "575", ...]
    #--
    # ok, but results should be filtered
    def right_neighbours(word, limit = 10)
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
      arg1 = ['Wort', word]
      arg2 = ['Limit', limit]
      answer = query(@cl_Similarity, arg1, arg2)
      
      get_answer(answer)
    end
    
    # This service delivers an experimental synonyms request for internal tests.
    #--
    # don't know, if we have to include this service...
    def experimental_synonyms(word, limit = 10)
      arg1 = ['Wort', word]
      arg2 = ['Limit', limit]
      answer = query(@cl_ExperimentalSynonyms, arg1, arg2)
      
      get_answer(answer)
    end
    
    ## Three parameter methods.
    #############################################################################
    
    # Attempts to find linguistic collocations that occur to the right
    # of the given input word.
    # The parameter 'Wortart' accepts four values 'A, V, N, S'
    # which stand for adjective, verb, noun and stopword respectively.
    # The parameter restricts the type of words found.
    # It returns an array:
    #   api.right_collocation_finder("Auto", "V", 10) =>
    #   ["Auto", "abfackeln", "V", ...]
    def right_collocation_finder(word, pos, limit = 10)
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
      arg1 = ['Wort', word]
      arg2 = ['Wortart', pos]
      arg3 = ['Limit', limit]
      answer = query(@cl_LeftCollocationFinder, arg1, arg2, arg3)
      
      get_answer(answer)
    end
    
    # Returns statistically significant co-occurrences of the input word.
    def cooccurrences(word, sign, limit = 10)
      arg1 = ['Wort', word]
      arg2 = ['Mindestsignifikanz', sign]
      arg3 = ['Limit', limit]
      raise NotImplementedError, 'Not implemented yet!'
    end
    
    # Returns statistically significant co-occurrences of the input word.
    # However, it searches in the unrestricted version of the co-occurrences table
    # as in the Cooccurrences services,
    # which means significantly longer wait times.
    def cooccurrences_all(word, sign, limit = 10)
      arg1 = ['Wort', word]
      arg2 = ['Mindestsignifikanz', sign]
      arg3 = ['Limit', limit]
      raise NotImplementedError, 'Not implemented yet!'
    end
    
    # Returns the intersection of the co-occurrences of the two given words.
    # The result set is ordered according to the sum of the significances
    # in descending order. Note that due to the join involved,
    # this make take some time.
    #--
    # let's call it intersection, not kookurrenzschnitt
    # is being used INTERN, we need additional credentials
    def intersection(word1, word2, limit = 10)
      arg1 = ['Wort 1', word1]
      arg2 = ['Wort 2', word2]
      arg3 = ['Limit', limit]
      # we are not going to implement it now
      raise NotImplementedError, 'Will never be implemented!'
    end
    
    private
    
    # Main query method, it invokes the soap engine.
    # It combines all the data to one SOAP request and gets the answer.
    # <args> contains an array [[key1, value1], [key2, value2], [key3, value3]]
    # with keys and values for the soap query.
    def query(cl, *args)
      # WSDL is disabled since calling the server for wsdl can last too long.
      resp = cl.request(:urn, :execute) do |soap|

        # Every service has a different namespace.
        soap.namespaces['xmlns:urn'] = cl.wsdl.namespace
        
        soap.namespaces['xmlns:dat'] =
          "http://datatypes.webservice.wortschatz.uni_leipzig.de"

        v = []
        body = {
          'urn:objRequestParameters' => {
            'urn:corpus' => 'de',
            'urn:parameters' => {
              'urn:dataVectors' => v
            }
          }
        }

        # Setting the first argument (usually 'Wort').
        v << {'dat:dataRow'=>[
                              args[0][0],
                              args[0][1]
                             ]
        } if args[0]
        # Setting the second argument (usually 'Limit').
        v << {'dat:dataRow'=>[
                              args[1][0],
                              args[1][1]
                             ]
        } if args[1]
        # Setting the third argument (no common value)
        v << {'dat:dataRow'=>[
                              args[2][0],
                              args[2][1]
                             ]
        } if args[2]

        soap.body = body
        warn(soap.to_xml) if $DEBUG

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

  end # class
end # module
