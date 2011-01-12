module GovKit
  class TransparencyDataResource < Resource
    default_params :apikey => GovKit::configuration.sunlight_apikey
    base_uri GovKit::configuration.transparency_data_base_url
  end

  module TransparencyData
    # See http://transparencydata.com/api/contributions/
    # for complete query options.
    class Contribution < TransparencyDataResource
      def self.find(ops = {})
        response = get('/contributions.json', :query => ops)
        parse(response)
      end
    end

    class Entity < TransparencyDataResource
      def self.find_by_id(id)
        response = get("/entities/#{id}.json")
        parse(response)
      end
    end
    
    class Categories
      # Contribution category code mapping table, in CSV format
      # Returns an array of hashes, each with the following keys:
      # :source, :code, :name, :industry, :order
      def self.all
        # This provides Ruby 1.8 & 1.9 CSV compatibility
        if CSV.const_defined? :Reader
          csv = FasterCSV
        else
          csv = CSV
        end
        categories = []
        open(GovKit::configuration.transparency_data_categories_url) do |f|
          csv.parse(f.read, :headers => true, :header_converters => :symbol) do |row|
           categories << row.to_hash
          end
        end
        categories
      end
    end
  end

end
