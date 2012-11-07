require 'nokogiri'
require 'open-uri'
require 'json'
require 'cgi'

module GovKit::OpenCongress
  autoload :Bill,               'gov_kit/open_congress/bill'
  autoload :BlogPost,           'gov_kit/open_congress/blog_post'
  autoload :NewsPost,           'gov_kit/open_congress/news_post'
  autoload :VotingComparison,   'gov_kit/open_congress/voting_comparison'
  autoload :RollCallComparison, 'gov_kit/open_congress/roll_call_comparison'
  autoload :Person,             'gov_kit/open_congress/person'
  autoload :PersonStat,         'gov_kit/open_congress/person_stat'

  # Parent class for classes that wrap {http://www.opencongress.org/api OpenCongress data}.
  #
  # Unlike the wrapper classes for data from {FollowTheMoneyResource FollowTheMoney}, 
  # {OpenStatesResource OpenStates}, {TransparencyDataResource TransparencyData}, 
  # and {VoteSmartResource VoteSmart}, OpenCongressObject does not inherit 
  # from {GovKit::Resource}
  #
  class OpenCongressObject
    
    def initialize(obj, params)
      params.each do |key, value|
        key = key.to_sym if RUBY_VERSION[0,3] == "1.9"
        instance_variable_set("@#{key}", value) if obj.instance_methods.include? key
      end      
    end

    # Create a query url, by adding the method path and query parameters to the
    # base url of {http://www.opencongress.org/api}.
    def self.construct_url(api_method, params)
      url = nil
      getkey = GovKit::configuration.opencongress_apikey.nil? ? "" : "&key=#{GovKit::configuration.opencongress_apikey}"
      url = "http://#{GovKit::configuration.opencongress_base_url}/#{api_method}?format=json#{hash2get(params)}#{getkey}"
      return url
    end

    # Convert a hash to a string of query parameters.
    #
    # @param [Hash] h a hash.
    # @return [String] a string of query parameters.
    def self.hash2get(h)
      get_string = ""
    
      h.each_pair do |key, value|
        get_string += "&#{key.to_s}=#{CGI::escape(value.to_s)}"
      end

      get_string
    end

    # Iterates through the array returned by {make_call}, 
    # converting each hash to an OpenCongressObject subclass.
    #
    # @param [Hash] results the array returned by make_call.
    # @return a hash of arrays of OpenCongressObject objects, with these keys: 
    #   * :also_supporting_bills 
    #   * :also_opposing_bills
    #   * :also_disapproved_senators
    #   * :also_disapproved_representatives
    #   * :also_approved_senators
    #   * :also_approved_representatives
    def self.parse_supporting_results(result)
      working = result["opencongress_users_tracking"]

      also_supporting_bills = []
      working["also_supporting_bills"]["bill"].each do |bill|
        also_supporting_bills << Bill.new(bill)
      end

      also_opposing_bills = []
      working["also_opposing_bills"]["bill"].each do |bill|
        also_opposing_bills << Bill.new(bill)
      end

      also_disapproved_senators = []
      working["also_disapproved_senators"]["person"].each do |person|
        also_disapproved_senators << Person.new(person)
      end

      also_disapproved_representatives = []
      working["also_disapproved_representatives"]["person"].each do |person|
        also_disapproved_representatives << Person.new(person)
      end

      also_approved_senators = []
      working["also_approved_senators"]["person"].each do |person|
        also_approved_senators << Person.new(person)
      end

      also_approved_representatives = []
      working["also_approved_representatives"]["person"].each do |person|
        also_approved_representatives << Person.new(person)
      end

      return {:also_supporting_bills => also_supporting_bills,
              :also_opposing_bills => also_opposing_bills,
              :also_disapproved_senators => also_disapproved_senators,
              :also_disapproved_representatives => also_disapproved_representatives,
              :also_approved_senators => also_approved_senators,
              :also_approved_representatives => also_approved_representatives}
    
    end
  
    # Get the data from {http://www.opencongress.org/api OpenCongress data}. Called by subclasses.
    #
    # Parses the data using {http://flori.github.com/json/doc/index.html JSON.parse}, which
    # returns an array of hashes.
    #
    # @return the returned data, as an array of hashes.
    def self.make_call(this_url)
      JSON.parse(open(this_url).read)
    end
  end
end
