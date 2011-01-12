module GovKit
  class Configuration
    attr_accessor :sunlight_apikey, :openstates_base_url, :transparency_data_base_url, :transparency_data_categories_url
    attr_accessor :votesmart_apikey, :votesmart_base_url
    attr_accessor :ftm_apikey, :ftm_base_url
    attr_accessor :opencongress_apikey, :opencongress_base_url
    attr_accessor :technorati_apikey, :technorati_base_url
    attr_accessor :google_blog_base_url, :google_news_base_url
    attr_accessor :wikipedia_base_url

    def initialize
      @openstates_apikey = @votesmart_apikey = @ftm_apikey = ''
      @openstates_base_url = 'openstates.sunlightlabs.com/api/v1/'
      @transparency_data_base_url = 'transparencydata.com/api/1.0/'
      @votesmart_base_url = 'api.votesmart.org/'
      @ftm_base_url = 'api.followthemoney.org/'
      @opencongress_base_url = 'www.opencongress.org/'
      @technorati_base_url = 'api.technorati.com'
      @google_blog_base_url = 'blogsearch.google.com'
      @google_news_base_url = 'news.google.com'
      @wikipedia_base_url = 'en.wikipedia.org'

      # Permant home for contribution category mappings
      @transparency_data_categories_url = 'http://assets.transparencydata.org.s3.amazonaws.com/docs/catcodes.csv'
    end
  end

  class << self
    attr_accessor :configuration
  end

  # Configure GovKit in config/initializers/govkit.rb
  #
  # @example
  #   GovKit.configure do |config|
  #     config.openstates_apikey = ''
  #   end
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end
