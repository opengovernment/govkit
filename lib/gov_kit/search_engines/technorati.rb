module GovKit
  module SearchEngines
    class TechnoratiSearch
      def self.search(options=[])
        query = options.to_query('q')
        host = "api.technorati.com"
        path = "/search?key=#{API_KEYS["technorati_api_key"]}&limit=50&language=en&query=#{query}"

        html = make_request(host, path)
        doc = Hpricot(Iconv.conv('utf-8//IGNORE', 'gb2312',html))

        citations = []
#        doc.search("tapi/document/item").each do |i|
#          citation = GovKit::Citation.new
#
#          citation.url = i.text("permalink")
#          citation.title = i.text("title")
#          citation.excerpt = i.text("excerpt")
#          citation.date = i.text("created")
#          citation.source = i.text("weblog/name")
#          citation.url = i.text("weblog/url")
#          citation.weight = i.text("weblog/inboundlinks")
#
#          citations << citation
#        end
        citations
        []
      end

      def self.make_request(host, path)
        response = Net::HTTP.get(host, path)
      end
    end
  end
end
