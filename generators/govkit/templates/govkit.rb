if defined? GovKit
  GovKit.configure do |config|
    # Get an API key for Sunlight's Open States project here:
    # http://services.sunlightlabs.com/accounts/register/
    config.sunlight_apikey = 'YOUR_SUNLIGHT_API_KEY'

    ##API key for Votesmart
    # http://votesmart.org/services_api.php
    config.votesmart_apikey = 'YOUR_VOTESMART_API_KEY'

    # API key for NIMSP. Request one here:
    # http://www.followthemoney.org/membership/settings.phtml
    config.ftm_apikey = 'YOUR_FTM_API_KEY'

    # Api key for OpenCongress
    # http://www.opencongress.org/api
    config.opencongress_apikey = 'YOUR_OPENCONGRESS_API_KEY'
    
    # Technorati API key
    config.technorati_apikey = 'YOUR_TECHNORATI_APIKEY'
    
    # Other things you could set here include alternate URLs for
    # the APIs. See GovKit::Configuration for available attributes.
  end
end
