require 'nokogiri'
require 'open-uri'
require 'json'

module GovKit::OpenCongress
  autoload :Bill,             'gov_kit/open_congress/bill'
  autoload :BlogPost,         'gov_kit/open_congress/blog_post'
  autoload :NewsPost,         'gov_kit/open_congress/news_post'
  autoload :VotingComparison, 'gov_kit/open_congress/voting_comparison'
  autoload :RollCallComparison, 'gov_kit/open_congress/roll_call_comparison'
  autoload :Person,           'gov_kit/open_congress/person'
  autoload :PersonStat,       'gov_kit/open_congress/person_stat'

  class OpenCongressObject

    def self.construct_url(api_method, params)
      url = nil
      if GovKit::configuration.opencongress_apikey == nil || GovKit::configuration.opencongress_apikey == ''
        raise "Failed to provide OpenCongress API Key"
      else
        url = "http://#{GovKit::configuration.opencongress_base_url}api/#{api_method}?key=#{GovKit::configuration.opencongress_apikey}#{hash2get(params)}&format=json"
      end
      return url
    end

    def self.hash2get(h)
      get_string = ""
    
      h.each_pair do |key, value|
        get_string += "&#{key.to_s}=#{CGI::escape(value.to_s)}"
      end

      get_string
    end

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
  
    def self.make_call(this_url)
      result = nil
      begin
        result = JSON.parse(open(this_url).read)
      rescue => e
        puts e
      end
    
      return result
    
    end
  end
end