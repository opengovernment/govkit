# Govkit

Govkit is a Ruby gem that provides simple access to open government APIs around the web.

# Installation

From gemcutter:

    gem install govkit

# Setup

Add govkit to your environment.rb or Gemfile

Run <code>./script/generate govkit</code> to copy a config file into <code>config/initializers/govkit.rb</code>. You will need to add your API keys to this config file.

# Example

[http://fiftystates-dev.sunlightlabs.com/](The Fifty States project) has a RESTful API for accessing data about state legislators, bills, votes, etc.

    >> Govkit::FiftyStates::State.find_by_abbreviation('CA')

(TODO: add usage examples...)

# Bugs? Questions?

Please join the [Govkit Google Group](http://groups.google.com/group/govkit), especially if you'd like to talk about a new feature and get announcements.

[Report a bug](https://participatorypolitics.lighthouseapp.com/projects/51485-govkit) on our Lighthouse page.

Govkit's main repo is on Github: [http://github.com/opengovernment/govkit](http://github.com/opengovernment/govkit), where your contributions, forks, and feedback are greatly welcomed.

Copyright (c) 2010 Participatory Politics Foundation, released under the MIT license
