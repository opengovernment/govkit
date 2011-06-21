module GovKit
  module OpenCongress

    class NewsPost < OpenCongressObject
    
      attr_accessor :title, :date, :url, :source_url, :excerpt, :source, :average_rating
      
    end
  
  end
end
