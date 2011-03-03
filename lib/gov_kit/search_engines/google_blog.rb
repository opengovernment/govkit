module GovKit
  module SearchEngines
    class GoogleBlog
      def self.search(options=[])
        query = options.join('+')
        host = GovKit::configuration.google_blog_base_url
        path = "/blogsearch_feeds?q=#{URI::encode(query)}&hl=en&output=rss&num=50"

        doc = Nokogiri::XML(make_request(host, path))

        mentions = []

        doc.xpath('//item').each do |i|
          mention = GovKit::Mention.new
          mention.title = i.xpath('title').inner_text
          mention.date = i.xpath('dc:date').inner_text
          mention.excerpt = i.xpath('description').inner_text
          mention.source = i.xpath('dc:publisher').inner_text
          mention.url = i.xpath('link').inner_text

          mentions << mention
        end
        mentions
      end

      def self.make_request(host, path)
        response = Net::HTTP.get(host, path)
      end
    end
  end
end
