module GovKit
  class TransparencyDataResource < Resource
    default_params :apikey => GovKit::configuration.sunlight_apikey
    base_uri GovKit::configuration.transparency_data_base_url
  end

  module TransparencyData
    # See http://transparencydata.com/api/contributions/
    # for complete query options
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
  end

end
