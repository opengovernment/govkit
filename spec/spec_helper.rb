require 'rubygems'
require 'rspec'
require 'fakeweb'
require File.dirname(__FILE__) + '/../lib/govkit'

# Set to true to run tests against the live URLs, and add the following to
# spec/support/api_keys.rb:
#
#     unless FakeWeb.allow_net_connect?
#       GovKit.configure do |config|
#         config.sunlight_apikey   = 'YOUR_SUNLIGHT_API_KEY'
#         config.votesmart_apikey  = 'YOUR_VOTESMART_API_KEY'
#         config.ftm_apikey        = 'YOUR_FTM_API_KEY'
#       end
#     end
FakeWeb.allow_net_connect = false

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each {|f| require f}

# prevent the use of `` in tests
RSpec.configure do |c|
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

FIXTURES_DIR = File.join(File.dirname(__FILE__), 'fixtures')
