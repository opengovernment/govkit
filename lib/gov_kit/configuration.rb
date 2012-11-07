module GovKit
  class Configuration
    attr_accessor :sunlight_apikey, :openstates_base_url, :transparency_data_base_url, :transparency_data_categories_url
    attr_accessor :votesmart_apikey, :votesmart_base_url
    attr_accessor :openstates_apikey, :ftm_apikey, :ftm_base_url
    attr_accessor :opencongress_apikey, :opencongress_base_url
    attr_accessor :technorati_apikey, :technorati_base_url
    attr_accessor :google_blog_base_url, :google_news_base_url
    attr_accessor :wikipedia_base_url
    attr_accessor :bing_appid, :bing_base_url

    def initialize
      @sunlight_apikey = @openstates_apikey = @votesmart_apikey = @ftm_apikey = ''
      @openstates_base_url = 'openstates.org/api/v1'
      @transparency_data_base_url = 'transparencydata.com/api/1.0'
      @votesmart_base_url = 'api.votesmart.org'
      @ftm_base_url = 'api.followthemoney.org'
      @opencongress_base_url = 'api.opencongress.org'
      @technorati_base_url = 'api.technorati.com'
      @bing_base_url = 'api.search.live.net'
      @google_blog_base_url = 'blogsearch.google.com'
      @google_news_base_url = 'news.google.com'
      @wikipedia_base_url = 'en.wikipedia.org'

      # Permant home for contribution category mappings
      @transparency_data_categories_url = 'http://assets.transparencydata.org.s3.amazonaws.com/docs/catcodes.csv'
    end
    
    def opencongress_apikey= key
      warn "[DEPRECATION] OpenCongress no longer requires an API Key. Ability to set it will be removed in future versions"
      @opencongress_apikey = key
    end

    def openstates_apikey= key
      warn "[DEPRECATION] Use sunlight_apikey instead of openstates_apikey. Ability to set it will be removed in future versions"
      @sunlight_apikey = key
    end
  end

  class << self
    attr_accessor :configuration
    
    def configuration
      @configuration = Configuration.new if @configuration.nil?
      @configuration
    end
  end

  # Configure GovKit in config/initializers/govkit.rb
  #
  # @example
  #   GovKit.configure do |config|
  #     config.sunlight_apikey = ''
  #   end
  def self.configure
    yield(configuration)
  end
end
