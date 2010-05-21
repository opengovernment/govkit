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

  module ActsAsCiteable
    def self.included(base)
      base.extend ActMethods
    end

    module ActMethods
      def acts_as_citeable(options={})
        options[:keywords] ||= []
        attr_accessor :keywords
        unless included_modules.include? InstanceMethods
          extend ClassMethods
          include InstanceMethods
        end
      end
    end

    module ClassMethods

    end

    module InstanceMethods
      def citations
        {
          :google_news => SearchEngines::GoogleNewsSearch.search(self.keywords),
          :google_blogs => SearchEngines::GoogleBlogSearch.search(self.keywords),
          :technorati => SearchEngines::TechnoratiSearch.search(self.keywords)
        }
      end
    end
  end
end
