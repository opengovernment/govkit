$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'active_support'
require 'gov_kit/configuration'
require 'gov_kit/search_engines/google_news'
require 'gov_kit/search_engines/google_blog_search'
require 'gov_kit/search_engines/technorati'

module GovKit
  autoload :FiftyStates, 'gov_kit/fifty_states'
  autoload :VoteSmart, 'gov_kit/vote_smart'

  class Bill < Resource; end
  class Vote < Resource; end
  class Session < Resource; end
  class Role < Resource; end
  class Legislator < Resource; end
  class Vote < Resource; end
  class Sponsor < Resource; end
  class Version < Resource; end
  class Source < Resource; end
  class Address < Resource; end
end
