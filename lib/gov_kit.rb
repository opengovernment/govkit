$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'digest/md5'
require 'nokogiri'
require 'iconv'
require 'httparty'
require 'open-uri'
require 'json'
require 'gov_kit/configuration'
require 'csv'

if RUBY_VERSION[0,3] == "1.8"
  require 'fastercsv'
end

module GovKit
  autoload :Resource, 'gov_kit/resource'
  autoload :OpenStates, 'gov_kit/open_states'
  autoload :TransparencyData, 'gov_kit/transparency_data'
  autoload :VoteSmart, 'gov_kit/vote_smart'
  autoload :ActsAsNoteworthy, 'gov_kit/acts_as_noteworthy'
  autoload :FollowTheMoney, 'gov_kit/follow_the_money'
  autoload :OpenCongress, 'gov_kit/open_congress'
  autoload :SearchEngines, 'gov_kit/search_engines'
  
  # Convenience class to represent a news story or blog post.
  # Used by GovKit::SearchEngines classes.
  class Mention
    attr_accessor :url, :excerpt, :title, :source, :date, :weight, :search_source
  end

  class GovKitError < StandardError
  end

  class NotAuthorized < GovKitError; end

  class InvalidRequest < GovKitError; end

  class ResourceNotFound < GovKitError; end
  
  class ServerError < GovKitError; end
  
  class ClientError < GovKitError; end
end
