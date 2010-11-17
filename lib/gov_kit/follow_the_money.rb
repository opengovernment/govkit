module GovKit
  class FollowTheMoneyResource < Resource
    default_params :key => GovKit::configuration.ftm_apikey
    base_uri GovKit::configuration.ftm_base_url

    def self.get_xml(path, options)
      doc = Nokogiri::XML(get(path, options))

      e = doc.search("//error")

      # Deal with whatever error comes back
      if e.size > 0
        raise case e.first.attributes['code'].value
        when "100"
          GovKit::NotAuthorized
        when "300"
          GovKit::InvalidRequest
        when "200"
          GovKit::ResourceNotFound
        else
          GovKit::InvalidRequest
        end, e.first.attributes['text'].value
      end

      doc
    end
    
    def self.stringify_values_of(result)
      # result is an array of hashes, but all the values are Nokogiri::XML::Attr objects, not strings.
      # We want them to be strings.
      result.collect! { |r| r.inject({}) {|h, (k, v)| h[k] = v.to_s; h } }
    end
  end

  module FollowTheMoney
    class Business < FollowTheMoneyResource
      def self.list
        next_page, result, page_num = "yes", [], 0

        until next_page != "yes"
          # puts "Getting batch number #{page_num}"

          doc = get_xml("/base_level.industries.list.php", :query => {:page => page_num})

          next_page = doc.children.first.attributes['next_page'].value

          page_num += 1

          result += doc.search('//business_detail').collect { |x| x.attributes }
        end

        stringify_values_of(result)
        parse(result)
      end
    end

    class Contribution < FollowTheMoneyResource
      def self.find(nimsp_id)
        next_page, result, page_num = "yes", [], 0

        until next_page != "yes"
          doc = get_xml("/candidates.contributions.php", :query => {"imsp_candidate_id" => nimsp_id, :page => page_num})

          next_page = doc.children.first.attributes['next_page'].value

          page_num += 1

          result += doc.search('//contribution').collect { |x| x.attributes }
        end

        stringify_values_of(result)
        parse(result)
      end

      def self.top(nimsp_id)
        doc = get_xml("/candidates.top_contributor.php", :query => {"imsp_candidate_id" => nimsp_id})
        result = doc.search('//top_contributor').collect { |x| x.attributes }

        stringify_values_of(result)
        parse(result)
      end
    end

    class IndustryContribution < Contribution
      def self.find(nimsp_id)
        doc = get_xml("/candidates.industries.php", :query => {"imsp_candidate_id" => nimsp_id})
        result = doc.search('//candidate_industry').collect { |x| x.attributes }

        stringify_values_of(result)
        parse(result)
      end
    end

    class SectorContribution < Contribution
      def self.find(nimsp_id)
        doc = get_xml("/candidates.sectors.php", :query => {"imsp_candidate_id" => nimsp_id})

        result = doc.search('//candidate_sector').collect { |x| x.attributes }

        stringify_values_of(result)
        parse(result)
      end
    end

    class BusinessContribution < Contribution
      def self.find(nimsp_id)
        doc = get_xml("/candidates.businesses.php", :query => {"imsp_candidate_id" => nimsp_id})

        result = doc.search('//candidate_business').collect { |x| x.attributes }

        stringify_values_of(result)
        parse(result)
      end
    end
  end
end
