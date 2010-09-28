module GovKit
  module SearchEngines
    class Wikipedia
      include HTTParty
      default_params :format => 'xml'
      base_uri "en.wikipedia.org"
      headers 'User-Agent' => 'GovKit +http://opengovernment.org'

      def self.search(query, options={})
        response = get("/wiki/#{query}")
        doc = Hpricot(Iconv.conv('utf-8//IGNORE', 'gb2312', response))

        bio = doc.at('#bodyContent > p:first').inner_html.scrub rescue ""

        return "" if bio =~ /may refer to:/

        bio
      end

      def self.make_request(host, path)
        response = Net::HTTP.get(host, path)
      end
    end
  end
end
