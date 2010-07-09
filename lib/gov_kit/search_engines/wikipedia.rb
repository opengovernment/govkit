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

        doc.at('#bodyContent > table.toc').previous_sibling.inner_html.scrub rescue ""
      end

      def self.make_request(host, path)
        response = Net::HTTP.get(host, path)
      end
    end
  end
end
