$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'active_support'
require 'hpricot'
require 'iconv'
require 'httparty'
require 'json'
require 'gov_kit/configuration'

module GovKit
  autoload :Resource, 'gov_kit/resource'
  autoload :FiftyStates, 'gov_kit/fifty_states'
  autoload :VoteSmart, 'gov_kit/vote_smart'
  autoload :ActsAsCiteable, 'gov_kit/acts_as_citeable'
  autoload :FollowTheMoney, 'gov_kit/follow_the_money'
  autoload :OpenCongress, 'gov_kit/open_congress'
  autoload :SearchEngines, 'gov_kit/search_engines'

  class Bill < Resource;
  end
  class Vote < Resource;
  end
  class Session < Resource;
  end
  class Role < Resource;
  end
  class Legislator < Resource;
  end
  class Vote < Resource;
  end
  class Sponsor < Resource;
  end
  class Version < Resource;
  end
  class Source < Resource;
  end
  class Address < Resource;
  end

  class Citation
    attr_accessor :url, :excerpt, :title, :source, :date, :weight
  end

end
