module GovKit
  module OpenCongress

    class NewsPost < OpenCongressObject
    
      attr_accessor :title, :date, :url, :source_url, :excerpt, :source, :average_rating
      
      def initialize(params)
        super NewsPost, params
      end
      
    end
  
  end
end
