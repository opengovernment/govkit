module GovKit 
  class FollowTheMoneyResource < Resource
    default_params :key => GovKit::configuration.ftm_apikey
    base_uri GovKit::configuration.ftm_base_url

    def self.get_xml(path, options)
      response = get(path, options)
      doc = Hpricot::XML(response)

      e = doc.search("//error")

      # API Key invalid
      if e.size > 0
        raise case e.first.attributes['code']
        when "100":
          GovKit::NotAuthorizedError
        when "300":
          GovKit::InvalidRequestError
        end, e.first.attributes['text']
      end

      doc
    end
  end

  module FollowTheMoney
    class Business < FollowTheMoneyResource
      def self.list
        next_page, result, page_num = "yes", [], 0

        until next_page != "yes"
          # puts "Getting batch number #{page_num}"

          doc = get_xml("/base_level.industries.list.php", :query => {:page => page_num})

          next_page = doc.search("/").first.attributes['next_page']

          page_num += 1

          result += doc.search('//business_detail').collect do |business|
            business.attributes.to_hash
          end
        end

        instantiate_collection(result)
      end
    end

    class Contribution < FollowTheMoneyResource
      def self.find(nimsp_id)
        next_page, result, page_num = "yes", [], 0

        until next_page != "yes"
          doc = get_xml("/candidates.contributions.php", :query => {"imsp_candidate_id" => nimsp_id, :page => page_num})

          next_page = doc.search("/").first.attributes['next_page']

          page_num += 1

          result = doc.search('//contribution').collect do |contribution|
            contribution.attributes.to_hash
          end
        end
        instantiate_collection(result)
      end

      def self.top(nimsp_id)
        doc = get_xml("/candidates.top_contributor.php", :query => {"imsp_candidate_id" => nimsp_id})

        result = doc.search('//top_contributor').collect do |contribution|
          contribution.attributes.to_hash
        end

        instantiate_collection(result)
      end
    end

    class IndustryContribution < Contribution
      def self.find(nimsp_id)
        doc = get_xml("/candidates.industries.php", :query => {"imsp_candidate_id" => nimsp_id})

        result = doc.search('//candidate_industry').collect do |contribution|
          contribution.attributes.to_hash
        end

        instantiate_collection(result)
      end
    end

    class SectorContribution < Contribution
      def self.find(nimsp_id)
        doc = get_xml("/candidates.sectors.php", :query => {"imsp_candidate_id" => nimsp_id})

        result = doc.search('//candidate_sector').collect do |contribution|
          contribution.attributes.to_hash
        end

        instantiate_collection(result)
      end
    end

    class BusinessContribution < Contribution
      def self.find(nimsp_id)
        doc = get_xml("/candidates.businesses.php", :query => {"imsp_candidate_id" => nimsp_id})

        result = doc.search('//candidate_business').collect do |contribution|
          contribution.attributes.to_hash
        end

        instantiate_collection(result)
      end
    end
  end
end
