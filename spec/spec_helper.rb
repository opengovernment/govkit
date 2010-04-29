require 'rubygems'
require 'spec'
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
