# Govkit

Govkit is a Ruby gem that provides simple access to open government APIs around the web, including:

 *  [OpenCongress](http://www.opencongress.org/api), which has an API for federal bills, votes, people, and news and blog coverage
 *  [The Fifty States project](http://fiftystates-dev.sunlightlabs.com/), which has a RESTful API for accessing data about state legislators, bills, votes, etc.
 *  [Project Vote Smart](http://www.votesmart.org/services_api.php), which has an API with congressional addresses, etc.
 *  [Follow The Money](http://www.followthemoney.org/), whose API reveals campaign contribution data for state officials.

# Installation

From gemcutter:

    gem install govkit

# Setup

Add govkit to your environment.rb or Gemfile

Run <code>./script/generate govkit</code> to copy a config file into <code>config/initializers/govkit.rb</code>. You will need to add your API keys to this config file.

# Examples

    >> Govkit::FiftyStates::State.find_by_abbreviation('CA')
    >> Govkit::VoteSmart::Address.find(votesmart_candidate_id)
    >> GovKit::OpenCongress::Bill.find(:number => 5479, :type => 'h', :congress => '111')

# Bugs? Questions?

Please join the [Govkit Google Group](http://groups.google.com/group/govkit), especially if you'd like to talk about a new feature and get announcements.

[Report a bug](https://participatorypolitics.lighthouseapp.com/projects/51485-govkit) on our Lighthouse page.

Govkit's main repo is on Github: [http://github.com/opengovernment/govkit](http://github.com/opengovernment/govkit), where your contributions, forks, and feedback are greatly welcomed.

Copyright (c) 2010 Participatory Politics Foundation, released under the MIT license
