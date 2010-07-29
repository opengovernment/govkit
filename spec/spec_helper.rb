require 'rubygems'
require 'spec'
require 'fakeweb'
require 'fakeweb_matcher'
require File.dirname(__FILE__) + '/../lib/govkit'

# prevent the use of `` in tests
Spec::Runner.configure do |configuration|
end

# When running specs in TextMate, provide an rputs method to cleanly print objects into HTML display
# From http://talklikeaduck.denhaven2.com/2009/09/23/rspec-textmate-pro-tip
module Kernel
  if ENV.keys.find {|env_var| env_var.index("TM_")}
    def rputs(*args)
      require 'cgi'
      puts( *["<pre>", args.collect {|a| CGI.escapeHTML(a.to_s)}, "</pre>"])
    end
    def rp(*args)
      require 'cgi'
      puts( *["<pre>", args.collect {|a| CGI.escapeHTML(a.inspect)}, "</pre>"])
    end
  else
    alias_method :rputs, :puts
    alias_method :rp, :p
  end
end

FakeWeb.allow_net_connect = false

FIXTURES_DIR = File.join(File.dirname(__FILE__), 'fixtures')

GovKit.configure do |config|
  config.openstates_apikey = 'YOUR_OPENSTATES_API_KEY'
  config.votesmart_apikey = 'YOUR_VOTESMART_API_KEY'
  config.ftm_apikey = 'YOUR_FTM_API_KEY'
  config.opencongress_apikey = 'YOUR_OPENCONGRESS_API_KEY'
end
