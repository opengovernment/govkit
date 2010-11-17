module GovKit
  module SearchEngines
    class Technorati
      def self.search(options=[])
        query = options.to_query('q')
        host = GovKit::configuration.technorati_base_url
        path = "/search?key=#{GovKit::configuration.technorati_apikey}&limit=50&language=en&query=#{URI::encode(query)}"

        doc = Nokogiri::HTML(make_request(host, path))

        mentions = []
#        doc.search("tapi/document/item").each do |i|
#          mention = GovKit::Mention.new
#
#          mention.url = i.text("permalink")
#          mention.title = i.text("title")
#          mention.excerpt = i.text("excerpt")
#          mention.date = i.text("created")
#          mention.source = i.text("weblog/name")
#          mention.url = i.text("weblog/url")
#          mention.weight = i.text("weblog/inboundlinks")
#
#          mentions << mention
#        end
        mentions
        []
      end

      def self.make_request(host, path)
        response = Net::HTTP.get(host, path)
      end
    end
  end
end
