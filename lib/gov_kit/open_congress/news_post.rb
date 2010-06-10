module GovKit
  module OpenCongress

    class NewsPost < OpenCongressObject
    
      attr_accessor :title, :date, :url, :source_url, :excerpt, :source, :average_rating
    
    
      def initialize(params)
        params.each do |key, value|
          instance_variable_set("@#{key}", value) if NewsPost.instance_methods.include? key
        end      
      end      
      
      
    end
  
  end
end
