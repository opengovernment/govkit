$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'active_support'
require 'govkit/configuration'

module Govkit
  autoload :FiftyStates, 'govkit/fifty_states'
  autoload :VoteSmart, 'govkit/vote_smart'
end
