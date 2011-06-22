module GovKit
  module OpenCongress
  
    class BlogPost < OpenCongressObject
    
      attr_accessor :title, :date, :url, :source_url, :excerpt, :source, :average_rating
      
      def initialize(params)
        super BlogPost, params
      end
      
    end
  
  end
end