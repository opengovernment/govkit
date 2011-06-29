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
        query = Array(query).join('+')
        host = GovKit::configuration.google_news_base_url
        options[:num] ||= 50

        path = "/news?q=#{URI::encode(query)}&output=rss" + '&' + options.map { |k, v| URI::encode(k.to_s) + '=' + URI::encode(v.to_s) }.join('&')

        doc = Nokogiri::XML(make_request(host, path))

        mentions = []

        doc.xpath('//item').each do |i|
          mention = GovKit::Mention.new
          mention.title = i.xpath('title').inner_text.split(" - ").first
          mention.date = i.xpath('pubDate').inner_text
          mention.excerpt = i.xpath('description').inner_text
          mention.source = i.xpath('title').inner_text.split(" - ").last
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
