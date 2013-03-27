module GovKit
  class TransparencyDataResource < Resource

    # default_params and base_uri are provided by HTTParty
    default_params :apikey => GovKit::configuration.sunlight_apikey
    base_uri GovKit::configuration.transparency_data_base_url

    def self.search_for( path, ops={} )
      response = get(path, :query => ops)
      # puts "response.parsed_response: #{response.parsed_response.inspect}"
      parse(response) 
    end

    # For testing.
    # Instantiate a GovKit::Resource object from sample data
    # To get the sample data, use the text returned by "response.parsed_response" in self.search_for
    def self.from_response response
      parse response
    end

  end

  module TransparencyData
    
    # Represents contributions. 
    #
    # See http://transparencydata.com/api/contributions/
    # for complete query options.

    class Contribution < TransparencyDataResource
      # Deprecated. Use search instead.
      def self.find(ops = {})
        puts "GovKit::TransparencyData::Contribution.find is deprecated. Use Contribution.search instead."
        response = get('/contributions.json', :query => ops)
        parse(response)
      end

      # Search for contribution records. 
      #
      # Example query:
      #   contributions = GovKit::TransparencyData::Contribution.search( { 'contributor_state' => 'md', 'recipient_ft' => 'mikulski', 'cycle' => '2008', 'per_page' => '3' } )
      def self.search(ops = {})
        search_for('/contributions.json', ops)
      end
    end

    # Represents government contracts.
    #
    # See http://transparencydata.com/api/contracts/
    # for complete query options.
    #
    class Contract < TransparencyDataResource
      # Search for contract records. 
      #
      # Example query:
      #   contracts = GovKit::TransparencyData::Contract.search( { :per_page => 2, :fiscal_year => 2008 } )
      def self.search(ops = {})
        search_for('/contracts.json', ops)
      end
    end
    
    # Represents entities -- politicians, individuals, or organizations.
    #
    # See http://transparencydata.com/api/aggregates/contributions/
    # for complete query options.
    
    class Entity < TransparencyDataResource
      # Deprecated for consistency of naming. Use find(id) instead.
      def self.find_by_id(id)
        puts "GovKit::TransparencyData::Entity.find_by_id is deprecated. Use Entity.find(id) instead."
        response = get("/entities/#{id}.json")
        parse(response)
      end

      # Find an entity by id.
      def self.find(id)
        response = get("/entities/#{id}.json")
        parse(response)
      end
      
      # Search for contract records. 
      #
      # Example query:
      #   entities = GovKit::TransparencyData::Entity.search('nancy+pelosi')
      def self.search(search_string)
        search_for("/entities.json", { :search => search_string } )
      end
    end

    # Represents lobbying activity.
    #
    # See http://transparencydata.com/api/lobbying/
    # for complete query options.

    class LobbyingRecord < TransparencyDataResource
      # Search for lobbying records. 
      #
      # Example query:
      #   lobbying_records = GovKit::TransparencyData::LobbyingRecord.search( { :per_page => 2 } )
      def self.search(ops = {})
        search_for('/lobbying.json', ops)
      end
    end
    
    # Represents government grants.
    #
    # See http://transparencydata.com/api/grants/
    # for complete query options.
    
    class Grant < TransparencyDataResource

      # Search for lobbying records. 
      #
      # Example query:
      #   grants = GovKit::TransparencyData::Grant.search( { :per_page => 2, :recipient_type => '00' } )

      def self.search(ops = {})
        search_for('/grants.json', ops)
      end
    end

    class Aggregate < TransparencyDataResource
      # generated URL:
      # http://transparencydata.com/api/1.0/aggregates/pol/4148b26f6f1c437cb50ea9ca4699417a/contributors/sectors.json?apikey=<key>&cycle=2012
      def self.top_sector_contributors(id, ops = {})
        response = get("/aggregates/pol/#{id}/contributors/sectors.json", :query => ops)
        parse(response)
      end

      # generated URL:
      # http://transparencydata.com/api/1.0/aggregates/pol/4148b26f6f1c437cb50ea9ca4699417a/contributors/type_breakdown.json?apikey=<key>&cycle=2012
      def self.contributor_type_breakdown(id, ops = {})
        response = get("/aggregates/pol/#{id}/contributors/type_breakdown.json", :query => ops)
        parse(response)
      end
      
      # generated URL:
      # http://transparencydata.com/api/1.0/aggregates/pol/4148b26f6f1c437cb50ea9ca4699417a/contributors/industries.json?apikey=<key>&cycle=2012
      def self.top_industry_contributors(id, ops = {})
        response = get("/aggregates/pol/#{id}/contributors/industries.json", :query => ops)
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
