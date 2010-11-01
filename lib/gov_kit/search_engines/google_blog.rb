module GovKit
  module SearchEngines
    class GoogleBlog
      def self.search(options=[])
        query = options.join('+')
        host = GovKit::configuration.google_blog_base_url
        path = "/blogsearch?hl=en&q=#{URI::encode(query)}&btnG=Search+Blogs&num=50"

        html = make_request(host, path)
        doc = Hpricot(Iconv.conv('utf-8//IGNORE', 'gb2312',html))
        stories = doc.search("td.j")
        titles = (doc/"a").select { |a| (a.attributes["id"] && a.attributes["id"].match(/p-(.*)/)) }

        mentions = []

        stories.each do |story|
          mention = GovKit::Mention.new
          t = titles.shift

          mention.title = (t.inner_html) if t #.unpack("C*").pack("U*") if t
          mention.url = t.attributes["href"] if t
          mention.date = story.at("font:nth(0)").inner_html
          mention.excerpt = (story.at("br + font").inner_html) #.unpack("C*").pack("U*")
          mention.source = story.at("a.f1").inner_html
          mention.url = story.at("a.f1").attributes["href"]

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
