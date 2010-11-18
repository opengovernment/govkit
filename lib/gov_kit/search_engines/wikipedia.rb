module GovKit
  module SearchEngines
    class Wikipedia
      include HTTParty
      default_params :format => 'xml'
      base_uri GovKit::configuration.wikipedia_base_url
      headers 'User-Agent' => 'GovKit +http://ppolitics.org'

      def self.search(query, options={})
        doc = Nokogiri::HTML(get("/wiki/#{query}"))

        bio = doc.at('#bodyContent > p:first').text rescue ""

        # Convert HTML => text.
        # bio = Loofah.fragment(bio).text

        return "" if bio =~ /may refer to:/

        bio
      end

      def self.make_request(host, path)
        response = Net::HTTP.get(host, path)
      end
    end
  end
end
