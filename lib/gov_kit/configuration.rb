module GovKit
  class Configuration
    attr_accessor :openstates_apikey, :openstates_base_url
    attr_accessor :votesmart_apikey, :votesmart_base_url
    attr_accessor :ftm_apikey, :ftm_base_url
    attr_accessor :opencongress_apikey, :opencongress_base_url

    def initialize
      @openstates_apikey = @votesmart_apikey = @ftm_apikey = ''
      @openstates_base_url = 'openstates.sunlightlabs.com/api/v1/'
      @votesmart_base_url = 'api.votesmart.org/'
      @ftm_base_url = 'api.followthemoney.org/'
      @opencongress_base_url = 'www.opencongress.org/'
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
