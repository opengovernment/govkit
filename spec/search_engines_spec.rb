require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module GovKit::SearchEngines
  describe GovKit::SearchEngines do
    before(:all) do
      google_news_uri = "http://news.google.com/"
      
      # An array of uris and filenames
      # Use FakeWeb to intercept net requests;
      # if a requested uri matches one of the following,
      # then return the contents of the corresponding file
      # as the result. 
      urls = [
       [ "news?q=congress&output=rss&num=50", "google_news.response" ] 
      ]
      
      urls.each do |u|
        FakeWeb.register_uri(:get, "#{google_news_uri}#{u[0]}", :response => File.join(FIXTURES_DIR, 'search_engines', u[1]))
      end
    end
    
    context "#GoogleNews" do
      it "should return results when passed an array" do
        lambda do
          @mentions = GoogleNews.search(["congress"])
        end.should_not raise_error
        
        @mentions.should be_an_instance_of(Array)
        @mentions.first.title.should == "White House and Congress Clear Trade Deal Hurdle"
        @mentions.first.source.should == "New York Times"
      end
      
      it "should return results when passed a string" do
        lambda do
          @mentions = GoogleNews.search("congress")
        end.should_not raise_error
        
        @mentions.should be_an_instance_of(Array)
        @mentions.first.title.should == "White House and Congress Clear Trade Deal Hurdle"
        @mentions.first.source.should == "New York Times"
      end
    end
  end
end