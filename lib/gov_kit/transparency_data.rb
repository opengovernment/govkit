module GovKit
  class TransparencyDataResource < Resource
    default_params :apikey => GovKit::configuration.sunlight_apikey
    base_uri GovKit::configuration.transparency_data_base_url

    def self.search_for( path, ops = {} )
      response = get(path, :query => ops)
      if response == []
        return response
      end
      parse(response) 
    end

  end

  module TransparencyData
    
    # See http://transparencydata.com/api/contributions/
    # for complete query options.
    class Contribution < TransparencyDataResource
      # Deprecated. Now use search instead.
      def self.find(ops = {})
        response = get('/contributions.json', :query => ops)
        parse(response)
      end

      def self.search(ops = {})
        search_for ('/contributions.json', ops)
      end
    end

    # See http://transparencydata.com/api/aggregates/contributions/
    # for complete query options.
    class Entity < TransparencyDataResource
      # Deprecated. Use find(id) instead.
      def self.find_by_id(id)
        response = get("/entities/#{id}.json")
        parse(response)
      end
      def self.find(id)
        response = get("/entities/#{id}.json")
        parse(response)
      end
      def self.search(ops = {})
        search_for("/entities.json", { :search => ops } )
      end
    end

    # See http://transparencydata.com/api/contracts/
    # for complete query options.
    class Contract < TransparencyDataResource
      def self.search(ops = {})
        search_for('/contracts.json', :query => ops)
      end
    end
    
    # See http://transparencydata.com/api/lobbying/
    # for complete query options.
    class LobbyingRecord < TransparencyDataResource
      def self.search(ops = {})
        search_for('/lobbying.json', :query => ops)
      end
    end
    
    # See http://transparencydata.com/api/grants/
    # for complete query options.
    class Grant < TransparencyDataResource
      def self.search(ops = {})
        search_for('/grants.json', :query => ops)
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
