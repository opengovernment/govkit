module GovKit

  # Parent class for OpenStates resources
  # See http://openstates.sunlightlabs.com/api/
  class OpenStatesResource < Resource
    base_uri GovKit::configuration.openstates_base_url

    # Do a GET query, with optional parameters.
    #
    # OpenStates returns a 404 error when a query
    # returns nothing.
    #
    # So, if a query result is a resource not found error,
    # we return an empty set.
    def self.get_uri(uri, options={})
      options[:query] ||= {}
      options[:query][:apikey] = GovKit::configuration.sunlight_apikey

      begin
        parse(get(URI.encode(uri), options))
      rescue ResourceNotFound
        []
      end
    end

  end

  # Ruby module for interacting with the Open States Project API
  # See http://openstates.sunlightlabs.com/api/
  # Most +find+ and +search+ methods: 
  # * call HTTParty::ClassMethods#get
  # * which returns an HTTParty::Response object
  # * which is passed to GovKit::Resource#parse
  # * which uses the response to populate a Resource
  #
  module OpenStates
    ROLE_MEMBER = "member"
    ROLE_COMMITTEE_MEMBER = "committee member"
    CHAMBER_UPPER = "upper"
    CHAMBER_LOWER = "lower"

    # The State class represents the state data returned from Open States.
    #
    # For details about fields returned, see the Open States documentation, at 
    # http://openstates.sunlightlabs.com/api/metadata/, 
    #
    class State < OpenStatesResource
      format :json

      def self.find_by_abbreviation(abbreviation)
        get_uri("/metadata/#{abbreviation}/")
      end
    end

    # The Bill class represents the bill data returned from Open States.
    #
    # For details about fields returned, see the Open States documentation, at 
    # http://openstates.sunlightlabs.com/api/bills/, 
    #
    class Bill < OpenStatesResource
      # http://openstates.sunlightlabs.com/api/v1/bills/ca/20092010/AB 667/
      def self.find(state_abbrev, session, bill_id, chamber = '')
        get_uri("/bills/#{state_abbrev.downcase}/#{session}/#{chamber.blank? ? '' : chamber + '/'}#{bill_id}/")
      end

      def self.search(query, options = {})
        result = get_uri('/bills/', :query => {:q => query}.merge(options))
        return Array(result)
      end

      def self.latest(updated_since, ops = {})
        result = get_uri('/bills/', :query => {:updated_since => updated_since.to_s}.merge(ops))
        return Array(result)
      end
    end

    # The Legislator class represents the legislator data returned from Open States.
    #
    # For details about fields returned, see the Open States documentation, at 
    # http://openstates.sunlightlabs.com/api/legislators/, 
    #
    class Legislator < OpenStatesResource
      def self.find(legislator_id)
        get_uri("/legislators/#{legislator_id}/")
      end

      def self.search(options = {})
        result = get_uri('/legislators/', :query => options)
        return Array(result)
      end
    end
    
    # The Committee class represents the committee data returned from Open States.
    #
    # For details about fields returned, see the Open States documentation, at 
    # http://openstates.sunlightlabs.com/api/committees/, 
    #
    class Committee < OpenStatesResource
      def self.find(committee_id)
        get_uri("/committees/#{committee_id}/")
      end

      def self.search(options = {})
        get_uri('/committees/', :query => options)
      end
    end
    
    class Role < OpenStatesResource; end

    class Sponsor < OpenStatesResource; end

    class Version < OpenStatesResource; end

    class Source < OpenStatesResource; end

    class Address < OpenStatesResource; end

    class Action < OpenStatesResource; end

    class Vote < OpenStatesResource
      def self.find(vote_id)
        response = get("/votes/#{vote_id}/")
        parse(response)
      end
    end
  end
end
