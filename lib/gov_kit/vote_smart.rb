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
  end
end
