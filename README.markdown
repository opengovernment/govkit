Govkit
======

Govkit is a Ruby gem that provides simple access to open government APIs around the web.

Setup
=====

Add govkit to your environment.rb or Gemfile

Run <pre>./script/generate govkit</pre> to copy a config file into config/initializers/govkit.rb. You will need to add your API keys to this config file.

Example
=======

The Fifty States project (http://fiftystates-dev.sunlightlabs.com/) has a RESTful API for accessing data about state legislators, bills, votes, etc.

>> Govkit::FiftyStates::State.find_by_abbrev('CA')


Bugs? Questions?
================

Please join the "Govkit Google Group":http://groups.google.com/group/govkit, especially if you'd like to talk about a new feature, or report a bug.

Govkit's main repo is on Github: "http://github.com/opengovernment/govkit":http://github.com/opengovernment/govkit, where your contributions, forkings, comments and feedback are greatly welcomed.


Copyright (c) 2010 Participatory Politics Foundation, released under the MIT license
