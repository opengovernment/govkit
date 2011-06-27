require 'uri'
require 'net/http'

module GovKit
  module SearchEngines

    # Class to wrap access to Google News.
    class GoogleNews

      # Fetches stories about a topic from google news.
      # Returns an array of GovKit::Mention objects.
      #
      # query: The query wanted For example:
      # mentions = GoogleNews.search("Nancy Pelosi")
      #
      # options: Any additional parameters to the search. eg.:
      # :geo => 'Texas' will add &geo=Texas to the URL.
      # :num => 100 will show 100 results per page.
      # 
      def self.search(query=[], options={})
        query = query.join('+')
        host = GovKit::configuration.google_news_base_url
        options[:num] ||= 50

        path = "/news/search?aq=f&pz=1&cf=all&ned=us&hl=en&as_epq=#{URI::encode(query)}&as_drrb=q&as_qdr=a" + '&' + options.map { |k, v| URI::encode(k.to_s) + '=' + URI::encode(v.to_s) }.join('&')

        doc = Nokogiri::HTML(make_request(host, path))

        stories = doc.search("div.search-results > div.story")

        mentions = []

        stories.each do |story|
          mention = GovKit::Mention.new

          mention.title = story.at("h2.title a").text
          mention.url = story.at("h2.title a").attributes["href"].value
          mention.search_source = 'Google News'          
          mention.date = story.at("div.sub-title > span.date").text
          mention.source = story.at("div.sub-title > span.source").text
          mention.excerpt = story.at("div.body > div.snippet").text

          mentions << mention
        end

        puts mentions.size.to_s + ' mentions from Google News'

        mentions
      end

      def self.make_request(host, path)
        response = Net::HTTP.get(host, path)
      end
    end
  end
end
