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

    class Category < VoteSmartResource
      def self.list(state_id)
        response = get("/Rating.getCategories", :query => {"stateId" => state_id})
        instantiate(response['categories']['category'])
      end
    end

    class SIG < VoteSmartResource
      def self.list(category_id, state_id)
        response = get("/Rating.getSigList", :query => {"categoryId" => category_id, "stateId" => state_id})
        instantiate(response['sigs']['sig'])
      rescue
        pp response
      end

      def self.find(sig_id)
        response = get("/Rating.getSig", :query => {"sigId" => sig_id})
        instantiate(response['sig'])
      end
    end

    class Rating < VoteSmartResource
      def self.find(candidate_id, sig_id)
        response = get("/Rating.getCandidateRating", :query => {"candidateId" => candidate_id, "sigId" => sig_id})
        instantiate(response['candidateRating']['rating'])
      rescue
        pp response
      end
    end

    class Bill < VoteSmartResource
      def self.find(bill_id)
        response = get('/Votes.getBill', :query => {'billId' => bill_id})
        instantiate_record(response['bill'])
      end

      def self.find_by_year_and_state(year, state_abbrev)
        response = get('/Votes.getBillsByYearState', :query => {'year' => year, 'stateId' => state_abbrev})
        instantiate_record(response['bills'])
      rescue
        return nil if response.parsed_response && response.parsed_response['error']['errorMessage'] == 'No bills for this state and year.'
        raise
      end

      
      def self.find_recent_by_state(state_abbrev)
        response = get('/Votes.getBillsByStateRecent', :query => {'stateId' => state_abbrev})
        instantiate_record(response['bills'])
      end
      
    end

    # See http://api.votesmart.org/docs/Committee.html
    class Committee < VoteSmartResource
      # Find a committee by VoteSmart typeId and stateId (abbreviation)
      # If type_id is nil, defaults to all types.
      # This method maps to Committee.getCommitteesByTypeState()
      def self.find_by_type_and_state(type_id, state_abbrev)
        response = get('/Committee.getCommitteesByTypeState', :query => {'typeId' => type_id, 'stateId' => state_abbrev})
        instantiate_record(response['committees'])
      end

      # Find a committee by VoteSmart committeeId. Maps to Committee.getCommittee()
      def self.find(committee_id)
        response = get('/Committee.getCommittee', :query => {'committeeId' => committee_id})
        instantiate_record(response['committee'])
      end
    end
  end
end
