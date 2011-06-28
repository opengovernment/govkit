module GovKit
  module SearchEngines
    class Bing
      def self.search(query=[], options={})
        host = GovKit::configuration.bing_base_url
        query = [query, options[:geo]].compact.join('+')

        options['Sources'] ||= 'news'

        path = "/json.aspx?Query=#{URI::encode(query)}&AppId=#{GovKit::configuration.bing_appid}&Sources=#{options['Sources']}"

        doc = JSON.parse(make_request(host, path))

        mentions = []

        if news_items = doc['SearchResponse']['News']
          puts "#{news_items['Results'].size} from Bing"
          news_items['Results'].each do |i|
            mention = GovKit::Mention.new
            mention.title = i['Title']
            mention.search_source = 'Bing'
            mention.date = DateTime.parse(i['Date'])
            mention.excerpt = i['Snippet']
            mention.source = i['Source']
            mention.url = i['Url']

            mentions << mention
          end
        end
        mentions
      end

      def self.make_request(host, path)
        Net::HTTP.get(host, path)
      end
    end
  end
end
