require 'uri'
require 'net/http'

module GovKit
  module SearchEngines
    class GoogleNews
      def self.search(options=[])
        query = options.join('+')
        host = GovKit::configuration.google_news_base_url
        path = "/news?hl=en&ned=us&q=#{URI::encode(query)}&btnG=Search+News&num=50"

        html = make_request(host, path)
        doc = Hpricot(Iconv.conv('utf-8//IGNORE', 'gb2312',html))
        stories = doc.search("div.search-results > div.story")

        mentions = []

        stories.each do |story|
          mention = GovKit::Mention.new

          mention.title = story.at("h2.title a").inner_text.html_safe
          mention.url = story.at("h2.title a").attributes["href"]
          mention.date = story.at("div.sub-title > span.date").inner_html.html_safe
          mention.source = story.at("div.sub-title > span.source").inner_html.html_safe
          mention.excerpt = story.at("div.body > div.snippet").inner_html.html_safe

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
