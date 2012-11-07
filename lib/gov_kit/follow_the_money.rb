module GovKit

  # Subclass of {Resource} for FollowTheMoney data. This 
  # is subclassed further for each of the different types of record
  # returned by FollowTheMoney.
  #
  # For the details on the FollowTheMoney queries, see {http://www.followthemoney.org/services/methods.phtml the FollowTheMoney API documentation}.
  class FollowTheMoneyResource < Resource
    base_uri GovKit::configuration.ftm_base_url
    format :xml

    # Common method used by subclasses to get data from the service.
    #
    # @return [Nokogiri::XML::Document] a {http://nokogiri.org/Nokogiri/HTML/Document.html Nokogiri XML::Document} object
    # @param [String] path query path that specifies the required data
    # @param [Hash]   options query options
    #
    # @example
    #   doc = get_xml("/base_level.industries.list.php", :query => {:page => page_num})
    #
    def self.get_xml(path, options)
      options[:query] ||= {}
      options[:query][:key] = GovKit::configuration.ftm_apikey

      doc = Nokogiri::XML(get(path, options).body)

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
    
  # Convert the hash array returned by Nokogiri, which has Nokogiri::XML::Attr objects as values,
  # to an array of hashes with string values.
  #
  # @param [Array] result array of hashes, with object values.
  # @return [Array] array of hashes, with string values.
    def self.stringify_values_of(result)
      result.collect! { |r| r.inject({}) {|h, (k, v)| h[k] = v.to_s; h } }
    end
  end

  # Provides classes to wrap {http://www.followthemoney.org/index.phtml FollowTheMoney} data. 
  #
  # For the details on the FollowTheMoney queries, see {http://www.followthemoney.org/services/methods.phtml the FollowTheMoney API documentation}.
  module FollowTheMoney

    # Wrap {http://www.followthemoney.org/services/method_doc.phtml?a=11 Industry data}
    class Business < FollowTheMoneyResource

      # Return a list of all business, industry, and sector categories. See the {http://www.followthemoney.org/services/method_doc.phtml?a=11 FollowTheMoney API}.
      #
      # @return [Business] A list of Business objects.
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

    # Wrap contributions to a candidate. See the {http://www.followthemoney.org/services/method_doc.phtml?a=32 FollowTheMoney API}.
    class Contribution < FollowTheMoneyResource

      # Return contributions to a candidate. See the {http://www.followthemoney.org/services/method_doc.phtml?a=32 FollowTheMoney API}.
      #
      # @param [Integer] nimsp_id the candidate id.
      #
      # @return [Contribution] a Contribution object, or array of Contribution objects, representing the contributions.
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

      # Return a list of the top contributors to a candidate. See the {http://www.followthemoney.org/services/method_doc.phtml?a=20 FollowTheMoney API}.
      #
      # @param [Integer] nimsp_id the candidate id.
      #
      # @return [[Contribution]] an array of Contribution objects.
      def self.top(nimsp_id)
        doc = get_xml("/candidates.top_contributor.php", :query => {"imsp_candidate_id" => nimsp_id})
        result = doc.search('//top_contributor').collect { |x| x.attributes }

        stringify_values_of(result)
        parse(result)
      end
    end

    # Wrap contributions by industry to a candidate. See the {http://www.followthemoney.org/services/method_doc.phtml?a=24 FollowTheMoney API}.
    #
    class IndustryContribution < Contribution
      # Return contributions by industry.
      #
      # @param [Integer] nimsp_id the candidate id.
      #
      # @return [[Contribution]] an array of Contribution objects.
      def self.find(nimsp_id)
        doc = get_xml("/candidates.industries.php", :query => {"imsp_candidate_id" => nimsp_id})
        result = doc.search('//candidate_industry').collect { |x| x.attributes }

        stringify_values_of(result)
        parse(result)
      end
    end

    # Wrap contributions by sector to a candidate. See the {http://www.followthemoney.org/services/method_doc.phtml?a=23 FollowTheMoney API}.
    #
    class SectorContribution < Contribution
      # Return conributions by sector.
      #
      # @param [Integer] nimsp_id the candidate id.
      #
      # @return [[Contribution]] an array of Contribution objects.
      def self.find(nimsp_id)
        doc = get_xml("/candidates.sectors.php", :query => {"imsp_candidate_id" => nimsp_id})

        result = doc.search('//candidate_sector').collect { |x| x.attributes }

        stringify_values_of(result)
        parse(result)
      end
    end

    # Wrap contributions by business to a candidate. See the {http://www.followthemoney.org/services/method_doc.phtml?a=25 FollowTheMoney API}.
    #
    class BusinessContribution < Contribution
      # Return contributions by business.
      #
      # @param [Integer] nimsp_id the candidate id.
      #
      # @return [[Contribution]] an array of Contribution objects.
      def self.find(nimsp_id)
        doc = get_xml("/candidates.businesses.php", :query => {"imsp_candidate_id" => nimsp_id})

        result = doc.search('//candidate_business').collect { |x| x.attributes }

        stringify_values_of(result)
        parse(result)
      end
    end
  end
end
