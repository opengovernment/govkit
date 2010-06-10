if defined? GovKit
  GovKit.configure do |config|
    # Get an API key for Sunlight's Fifty States project here:
    # http://services.sunlightlabs.com/accounts/register/
    config.fiftystates_apikey = 'YOUR_FIFTYSTATES_API_KEY'

    ##API key for Votesmart
    # http://votesmart.org/services_api.php
    config.votesmart_apikey = 'YOUR_VOTESMART_API_KEY'
    
    # API key for NIMSP. Request one here:
    # http://www.followthemoney.org/membership/settings.phtml
    config.ftm_apikey = 'YOUR_FTM_API_KEY'
    
    # Api key for OpenCongress
    # http://www.opencongress.org/api
    config.opencongress_apikey = 'YOUR_OPENCONGRESS_API_KEY'
  end
end
