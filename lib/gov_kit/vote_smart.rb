module GovKit
  class VoteSmartResource < Resource
    default_params :o => 'JSON', :key => GovKit::configuration.votesmart_apikey
    base_uri GovKit::configuration.votesmart_base_url
  end

  module VoteSmart
    class Address < VoteSmartResource
      def self.find(candidate_id)
        response = get("/Address.getOffice", :query => {"candidateId" => candidate_id})
        parse(response['address'])
      end
    end

    class WebAddress < VoteSmartResource
      def self.find(candidate_id)
        response = get("/Address.getOfficeWebAddress", :query => {"candidateId" => candidate_id})
        parse(response['webaddress'])
      end
    end

    class Bio < VoteSmartResource
      def self.find(candidate_id)
        response = get("/CandidateBio.getBio", :query => {"candidateId" => candidate_id})

        # Sometimes VoteSmart returns nil if no one is found!
        raise(ResourceNotFound, 'Could not find bio for candidate') if response.blank? || response['error']

        parse(response['bio']['candidate'])
      end
    end

    class Category < VoteSmartResource
      def self.list(state_id)
        response = get("/Rating.getCategories", :query => {"stateId" => state_id})
        parse(response['categories']['category'])
      end
    end

    class SIG < VoteSmartResource
      def self.list(category_id, state_id)
        response = get("/Rating.getSigList", :query => {"categoryId" => category_id, "stateId" => state_id})

        raise(ResourceNotFound, response['error']['errorMessage']) if response['error']

        parse(response['sigs']['sig'])
      end

      def self.find(sig_id)
        response = get("/Rating.getSig", :query => {"sigId" => sig_id})
        parse(response['sig'])
      end
    end

    class Rating < VoteSmartResource
      def self.find(candidate_id, sig_id)
        response = get("/Rating.getCandidateRating", :query => {"candidateId" => candidate_id, "sigId" => sig_id})

        raise(ResourceNotFound, response['error']['errorMessage']) if response['error']

        parse(response['candidateRating']['rating'])
      end
    end

    class Bill < VoteSmartResource
      def self.find(bill_id)
        response = get('/Votes.getBill', :query => {'billId' => bill_id})
        parse(response['bill'])
      end

      def self.find_by_year_and_state(year, state_abbrev)
        response = get('/Votes.getBillsByYearState', :query => {'year' => year, 'stateId' => state_abbrev})
        raise(ResourceNotFound, response['error']['errorMessage']) if response['error'] && response['error']['errorMessage'] == 'No bills for this state and year.'

        parse(response['bills'])
      end

      def self.find_recent_by_state(state_abbrev)
        response = get('/Votes.getBillsByStateRecent', :query => {'stateId' => state_abbrev})
        parse(response['bills'])
      end
      
      def self.find_by_category_and_year_and_state(category_id, year, state_abbrev = nil)
        response = get('/Votes.getBillsByCategoryYearState', :query => {'stateId' => state_abbrev, 'year' => year, 'categoryId' => category_id})
        raise(ResourceNotFound, response['error']['errorMessage']) if response['error'] && response['error']['errorMessage'] == 'No bills for this state, category, and year.'

        parse(response['bills'])
      end

      def self.find_by_category_and_year(category_id, year)
        find_by_category_and_year_and_state(category_id, year)
      end
    end
    
    class BillCategory < VoteSmartResource
      def self.find(year, state_abbrev)
        response = get("/Votes.getCategories", :query => {'year' => year, 'stateId' => state_abbrev})
        parse(response['categories']['category'])
      end
    end

    # See http://api.votesmart.org/docs/Committee.html
    class Committee < VoteSmartResource
      # Find a committee by VoteSmart typeId and stateId (abbreviation)
      # If type_id is nil, defaults to all types.
      # This method maps to Committee.getCommitteesByTypeState()
      def self.find_by_type_and_state(type_id, state_abbrev)
        response = get('/Committee.getCommitteesByTypeState', :query => {'typeId' => type_id, 'stateId' => state_abbrev})
        parse(response['committees'])
      end

      # Find a committee by VoteSmart committeeId. Maps to Committee.getCommittee()
      def self.find(committee_id)
        response = get('/Committee.getCommittee', :query => {'committeeId' => committee_id})
        parse(response['committee'])
      end
    end
  end
end
