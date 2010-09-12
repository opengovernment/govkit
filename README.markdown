# Govkit

Govkit is a Ruby gem that provides simple access to open government APIs around the web, including:

 *  [OpenCongress](http://www.opencongress.org/api), which has an API for federal bills, votes, people, and news and blog coverage
 *  [The Open States project](http://fiftystates-dev.sunlightlabs.com/), which has a RESTful API for accessing data about state legislators, bills, votes, etc.
 *  [Project Vote Smart](http://www.votesmart.org/services_api.php), which has an API with congressional addresses, etc.
 *  [Follow The Money](http://www.followthemoney.org/), whose API reveals campaign contribution data for state officials.

# Installation

From gemcutter:

    gem install govkit

# Setup

Add govkit to your environment.rb or Gemfile

Run <code>rails generate govkit</code> (Rails 3.x) or <code>script/generate govkit</code> (Rails 2.x) to copy a config file into <code>config/initializers/govkit.rb</code>. You will need to add your API keys to this config file.

# Usage Examples

    >> GovKit::OpenStates::State.find_by_abbreviation('CA')
    >> GovKit::VoteSmart::Address.find(votesmart_candidate_id)
    >> GovKit::OpenCongress::Bill.find(:number => 5479, :type => 'h', :congress => '111')

Objects returned from GovKit will have attributes for each field coming back from the API:

    >> x = GovKit::OpenStates::State.find_by_abbreviation('CA')
    => #<GovKit::OpenStates::State:0x00000100f6a5a8 @attributes={"lower_chamber_title"=>"Assemblymember", "lower_chamber_name"=>"Assembly", "upper_chamber_title"=>"Senator", "terms"=>[#<GovKit::OpenStates::State::Term:0x00000100f2a8e0 @attributes={"....
    >> x.name
    => "California"

GovKit will raise GovKit::ResourceNotFound if a requested item isn't available.

# Testing & Debugging

For debugging purposes, there's a raw_response reader provided for each object, which typically returns an HTTParty::Response object. To see the body of the HTTP response, you might look here:

    (continuing the example from above)
    >> x.raw_response.response.body
    => "{\n    \"lower_chamber_title\": \"Assemblymember\", \n    \"lower_chamber_name\": \"Assembly\", \n  ....

# Bugs? Questions?

Please join the [Govkit Google Group](http://groups.google.com/group/govkit), especially if you'd like to talk about a new feature and get announcements.

[Report a bug](https://participatorypolitics.lighthouseapp.com/projects/51485-govkit) on our Lighthouse page.

Govkit's main repo is on Github: [http://github.com/opengovernment/govkit](http://github.com/opengovernment/govkit), where your contributions, forks, and feedback are greatly welcomed.

Copyright (c) 2010 Participatory Politics Foundation, released under the MIT license
