module GovKit
  class VoteSmartResource < Resource
    default_params :o => 'JSON', :key => GovKit::configuration.votesmart_apikey
    base_uri GovKit::configuration.votesmart_base_url
  end

  module VoteSmart
    class Address < VoteSmartResource
      def self.find(candidate_id)
        response = get("/Address.getOffice", :query => {"candidateId" => candidate_id})
        instantiate_record(response['address'])
      end
    end

    class WebAddress < VoteSmartResource
      def self.find(candidate_id)
        response = get("/Address.getOfficeWebAddress", :query => {"candidateId" => candidate_id})
        instantiate_record(response['webaddress'])
      end
    end

    class Bio < VoteSmartResource
      def self.find(candidate_id)
        response = get("/CandidateBio.getBio", :query => {"candidateId" => candidate_id})
        instantiate_record(response['bio']['candidate'])
      end
    end

    class Bill < VoteSmartResource
      def self.find(bill_id)
        response = get("/Votes.getBill", :query => {"billId" => bill_id})
        instantiate_record(response['bill'])
      end

      def self.find_by_year_and_state(year, state_abbrev)
        response = get("/Votes.getBillsByYearState", :query => {"year" => year, "stateId" => state_abbrev})
        instantiate_record(response['bills'])
      end
    end

    # See http://api.votesmart.org/docs/Committee.html
    class Committee < VoteSmartResource
      # Find a committee by VoteSmart typeId and stateId (abbreviation)
      # If type_id is nil, defaults to all types.
      # This method maps to Committee.getCommitteesByTypeState()
      def self.find_by_type_and_state(type_id, state_abbrev)
        response = get("/Committee.getCommitteesByTypeState", :query => {"typeId" => type_id, "stateId" => state_abbrev})
        instantiate_record(response['committees'])
      end

      # Find a committee by VoteSmart committeeId. Maps to Committee.getCommittee()
      def self.find(committee_id)
        response = get("/Committee.getCommittee", :query => {"committeeId" => committee_id})
        instantiate_record(response['committee'])
      end
    end
  end
end
