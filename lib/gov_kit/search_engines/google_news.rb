require 'uri'
require 'net/http'

module GovKit
  module SearchEngines
    class GoogleNews
      def self.search(options=[])
        query = options.join('+')
        host = "news.google.com"
        path = "/news?hl=en&ned=us&q=#{URI::encode(query)}&btnG=Search+News&num=50"

        html = make_request(host, path)
        doc = Hpricot(Iconv.conv('utf-8//IGNORE', 'gb2312',html))
        stories = doc.search("div.search-results > div.story")

        citations = []

        stories.each do |story|
          citation = GovKit::Citation.new

          citation.title = story.at("h2.title a").inner_text.html_safe!
          citation.url = story.at("h2.title a").attributes["href"]
          citation.date = story.at("div.sub-title > span.date").inner_html.html_safe!
          citation.source = story.at("div.sub-title > span.source").inner_html.html_safe!
          citation.excerpt = story.at("div.body > div.snippet").inner_html.html_safe!

          citations << citation
        end
        citations
      end

      def self.make_request(host, path)
        puts host+path
        response = Net::HTTP.get(host, path)
      end
    end
  end
end
