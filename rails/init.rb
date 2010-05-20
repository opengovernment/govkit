# Include hook code here
require File.join(File.dirname(__FILE__), *%w[.. lib govkit])
ActiveRecord::Base.send(:include, GovKit::ActsAsCiteable)
