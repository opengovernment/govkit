module GovKit

  # Parent class for OpenStates resources
  # See http://openstates.sunlightlabs.com/api/
  class OpenStatesResource < Resource

    # Uses default_params from the HTTParty gem.
    # See HTTParty::ClassMethods:
    # http://rubydoc.info/gems/httparty/0.7.4/HTTParty/ClassMethods#default_params-instance_method
    default_params :output => 'json', :apikey => GovKit::configuration.sunlight_apikey
    base_uri GovKit::configuration.openstates_base_url
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
      def self.find_by_abbreviation(abbreviation)
        response = get("/metadata/#{abbreviation}/")
        parse(response)
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
        escaped_bill_id = bill_id.gsub(/ /, '%20')
        escaped_session = session.gsub(/ /, '%20')
        response = get("/bills/#{state_abbrev.downcase}/#{escaped_session}/#{chamber.blank? ? '' : chamber + '/'}#{escaped_bill_id}/")
        parse(response)
      end

      def self.search(query, options = {})
        response = get('/bills/', :query => {:q => query}.merge(options))
        parse(response)
      end

      def self.latest(updated_since, ops = {})
        response = get('/bills/', :query => {:updated_since => updated_since.to_s}.merge(ops))
        parse(response)
      end
    end

    # The Legislator class represents the legislator data returned from Open States.
    #
    # For details about fields returned, see the Open States documentation, at 
    # http://openstates.sunlightlabs.com/api/legislators/, 
    #
    class Legislator < OpenStatesResource
      def self.find(legislator_id)
        response = get("/legislators/#{legislator_id}/")
        parse(response)
      end

      def self.search(options = {})
        response = get('/legislators/', :query => options)
        parse(response)
      end
    end
    
    # The Committee class represents the committee data returned from Open States.
    #
    # For details about fields returned, see the Open States documentation, at 
    # http://openstates.sunlightlabs.com/api/committees/, 
    #
    class Committee < OpenStatesResource
      def self.find(committee_id)
        response = get("/committees/#{committee_id}/")
        parse(response)
      end

      def self.search(options = {})
        response = get('/committees/', :query => options)
        parse(response)
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
