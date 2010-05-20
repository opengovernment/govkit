module GovKit
  module SearchEngines
    class GoogleBlogSearch
      def self.search(options=[])
        query = options.to_query('q')
        host = "blogsearch.google.com"
        path = "/blogsearch?hl=en&q=#{query}&btnG=Search+Blogs&num=50"

        html = make_request(host, path)
        doc = Hpricot(html)
        stories = doc.search("td.j")
        titles = (doc/"a").select { |a| (a.attributes["id"] && a.attributes["id"].match(/p-(.*)/)) }

        citations = []

        stories.each do |story|
          citation = GovKit::Citation.new
          t = titles.shift

          citation.title = (t.inner_html) if t #.unpack("C*").pack("U*") if t
          citation.url = t.attributes["href"] if t
          citation.date = story.at("font:nth(0)").inner_html
          citation.excerpt = (story.at("br + font").inner_html) #.unpack("C*").pack("U*")
          citation.source = story.at("a.f1").inner_html
          citation.url = story.at("a.f1").attributes["href"]

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
