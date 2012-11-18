module GovKit
  class VoteSmartResource < Resource
    default_params :o => 'JSON', :key => GovKit::configuration.votesmart_apikey
    base_uri GovKit::configuration.votesmart_base_url
  end

  module VoteSmart
    class State < VoteSmartResource
      def self.find_all
        response = get("/State.getStateIDs")
        parse(response['stateList']['list']['state'])
      end
      
      def self.find_counties(stateId)
        response = get("/Local.getCounties", :query => {"stateId" => stateId})
        return [] if !response['counties']

        if response['counties']['county'].instance_of?(Array)
          parse(response['counties']['county'])
        else
          [ parse(response['counties']['county']) ]         
        end
      end
      
      def self.find_cities(stateId)
        response = get("/Local.getCities", :query => {"stateId" => stateId})
        return [] if !response['cities']
        
        if response['cities']['city'].instance_of?(Array)
          parse(response['cities']['city'])
        else
          [ parse(response['cities']['city']) ]         
        end
      end
    end

    class Official < VoteSmartResource
      def self.find_all(stateOrLocalId)
        if stateOrLocalId.match(/[A-Za-z]/) # We're looking for state officals
          response = get("/Officials.getStatewide", :query => {"stateId" => stateOrLocalId})
        else # We're looking for local officials
          response = get("/Local.getOfficials", :query => {"localId" => stateOrLocalId})
        end
        
        return [] if !response['candidateList']
        
        if response['candidateList']['candidate'].instance_of?(Array)
          parse(response['candidateList']['candidate'])
        else
          [ parse(response['candidateList']['candidate']) ]
        end
      end
      
      def self.find_by_office_state(officeId, stateId = 'NA')
        response = get("/Officials.getByOfficeState", :query => { "officeId" => officeId,
                                                                  "stateId" => stateId })
                                                          
        return [] if !response['candidateList']
        
        if response['candidateList']['candidate'].instance_of?(Array)
          parse(response['candidateList']['candidate'])
        else
          [ parse(response['candidateList']['candidate']) ]
        end
      end
    end
    
    class Address < VoteSmartResource
      def self.find(candidate_id)
        response = get("/Address.getOffice", :query => {"candidateId" => candidate_id})
        parse(response['address'])
      end
    end

    class WebAddress < VoteSmartResource
      def self.find(candidate_id)
        response = get("/Address.getOfficeWebAddress", :query => {"candidateId" => candidate_id})
        
        return [] if !response['webaddress']
        
        if response['webaddress']['address'].instance_of?(Array)
          parse(response['webaddress']['address'])
        else
          [ parse(response['webaddress']['address']) ]          
        end
      end
    end

    class Bio < VoteSmartResource
      def self.find(candidate_id, include_office = false)
        response = get("/CandidateBio.getBio", :query => {"candidateId" => candidate_id})

        return false if response.blank? || response['error']
        
        # Previous versions ommitted "office" data from response.
        # include_office is optional so to not break backwards compatibility.
        if include_office
          parse(response['bio'])
        else
          parse(response['bio']['candidate'])          
        end
      end
    end

    class Category < VoteSmartResource
      def self.list(state_id)
        response = get("/Rating.getCategories", :query => {"stateId" => state_id})

        raise(ResourceNotFound, response['error']['errorMessage']) if response['error']

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

    class BillAction < VoteSmartResource
      def self.find(action_id)
        response = get('/Votes.getBillAction', :query => {'actionId' => action_id})
        parse(response['action'])
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
