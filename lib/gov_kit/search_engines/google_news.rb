require 'uri'
require 'net/http'

module GovKit
  module SearchEngines
    class GoogleNews
      def self.search(options=[])
        query = options.join('+')
        host = GovKit::configuration.google_news_base_url
        path = "/news?hl=en&ned=us&q=#{URI::encode(query)}&btnG=Search+News&num=50"

        doc = Nokogiri::HTML(make_request(host, path))
        stories = doc.search("div.search-results > div.story")

        mentions = []

        stories.each do |story|
          mention = GovKit::Mention.new

          mention.title = story.at("h2.title a").text
          mention.url = story.at("h2.title a").attributes["href"].value
          mention.date = story.at("div.sub-title > span.date").text
          mention.source = story.at("div.sub-title > span.source").text
          mention.excerpt = story.at("div.body > div.snippet").text

          mentions << mention
        end
        mentions
      end

      def self.make_request(host, path)
        puts host+path
        response = Net::HTTP.get(host, path)
      end
    end
  end
end
