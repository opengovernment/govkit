require 'uri'
require 'net/http'

module GovKit
  module SearchEngines
    class GoogleNewsSearch
      def self.search(options=[])
        query = options.to_query('q')
        host = "news.google.com"
        path = "/news?hl=en&ned=us&q=#{query}&btnG=Search+News&num=50"

        html = make_request(host, path)
        doc = Hpricot(html)
        stories = doc.search("div.search-results > div.story")

        citations = []

        stories.each do |story|
          citation = GovKit::Citation.new

          citation.title = story.at("h2.title a").inner_text
          citation.url = story.at("h2.title a").attributes["href"]
          citation.date = story.at("div.sub-title > span.date").inner_html
          citation.source = story.at("div.sub-title > span.source").inner_html
          citation.excerpt = story.at("div.body > div.snippet").inner_html #.unpack("C*").pack("U*")

          citations << citation
        end
        citations
      end

      def self.make_request(host, path)
        response = Net::HTTP.get(host, path)
      end
    end
  end
end
