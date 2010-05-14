if defined? GovKit
  GovKit.configure do |config|
    # Get an API key for Sunlight's Fifty States project here:
    # http://services.sunlightlabs.com/accounts/register/
    config.fiftystates_apikey = 'YOUR_FIFTYSTATES_API_KEY'

    ##API key for votesmart
    #http://votesmart.org/services_api.php
    config.votesmart_apikey = 'YOUR_VOTESMART_API_KEY'
  end
end
