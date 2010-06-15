module GovKit
  class FiftyStatesResource < Resource
    default_params :output => 'json', :apikey => GovKit::configuration.fiftystates_apikey
    base_uri GovKit::configuration.fiftystates_base_url
  end

  module FiftyStates
    ROLE_MEMBER = "member"
    ROLE_COMMITTEE_MEMBER = "committee member"
    CHAMBER_UPPER = "upper"
    CHAMBER_LOWER = "lower"

    class State < FiftyStatesResource
      def self.find_by_abbreviation(abbreviation)
        response = get("/#{abbreviation}/")
        instantiate_record(response)
      end
    end

    class Bill < FiftyStatesResource
      # http://fiftystates-dev.sunlightlabs.com/api/ca/20092010/lower/bills/AB667/
      def self.find(state_abbrev, session, chamber, bill_id)
        response = get("/#{state_abbrev}/#{session}/#{chamber}/bills/#{bill_id}/")
        instantiate_record(response)
      end

      def self.search(query, options = {})
        response = get('/bills/search/', :query => {:q => query}.merge(options))
        instantiate_collection(response)
      end

      def self.latest(updated_since, state_abbrev)
        response = get('/bills/latest/', :query => {:updated_since => updated_since, :state => state_abbrev})
        instantiate_collection(response)
      end
    end

    class Legislator < FiftyStatesResource
      def self.find(legislator_id)
        response = get("/legislators/#{legislator_id}/")
        instantiate_record(response)
      end

      def self.search(options = {})
        response = get('/legislators/search/', :query => options)
        instantiate_collection(response)
      end
    end

    class Vote < FiftyStatesResource
      def self.find(vote_id)
        response = get("/votes/#{vote_id}/")
        instantiate_record(response)
      end
    end
  end
end
