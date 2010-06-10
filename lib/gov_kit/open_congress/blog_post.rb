module GovKit
  module OpenCongress
  
    class BlogPost < OpenCongressObject
    
      attr_accessor :title, :date, :url, :source_url, :excerpt, :source, :average_rating
    
    
      def initialize(params)
        params.each do |key, value|
          instance_variable_set("@#{key}", value) if BlogPost.instance_methods.include? key
        end      
      end      
      
      
    end
  
  end
end