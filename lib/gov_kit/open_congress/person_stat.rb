module GovKit
  module OpenCongress
    class PersonStat < OpenCongressObject
    
      attr_accessor :votes_most_often_with_id, :opposing_party_votes_most_often_with_id, :votes_least_often_with_id, :same_party_votes_least_often_with_id, :party_votes_percentage, :abstains_percentage, :abstains_percentage_rank, :party_votes_percentage_rank, :sponsored_bills, :cosponsored_bills, :abstains, :sponsored_bills_passed_rank, :cosponsored_bills_passed_rank, :sponsored_bills_passed, :cosponsored_bills_passed, :sponsored_bills_rank, :cosponsored_bills_rank
    
    
      def initialize(params)
        params.each do |key, value|
          instance_variable_set("@#{key}", value) if PersonStat.instance_methods.include? key
        end      
      end      
      
      
    end
  
  end
end
