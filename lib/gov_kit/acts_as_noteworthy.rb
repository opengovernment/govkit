module GovKit::ActsAsNoteworthy

  def self.included(base)
    base.extend ActMethods
  end

  # Module to make a rails model act as a noteworthy object, linking it to govkit's mention model
  module ActMethods
    # Sets up the relationship between the model and the mention model
    # 
    # @param [Hash] opts a hash of options to be used by the relationship
    def acts_as_noteworthy(options={})
      class_inheritable_accessor :options
      self.options = options

      unless included_modules.include? InstanceMethods
        instance_eval do
          has_many :mentions, :as => :owner, :order => 'date desc'

          with_options :as => :owner, :class_name => "Mention" do |c|
            c.has_many :google_news_mentions, :conditions => {:search_source => "Google News"}, :order => 'date desc'
            c.has_many :google_blog_mentions, :conditions => {:search_source => "Google Blogs"}, :order => 'date desc'
#            c.has_many :technorati_mentions, :conditions => {:search_source => "Technorati"}, :order => 'date desc'
            c.has_many :bing_mentions, :conditions => {:search_source => "Bing"}, :order => 'date desc'
          end
        end

        extend ClassMethods
        include InstanceMethods
      end
    end
  end

  module ClassMethods
  end
  
  # A module that adds methods to individual instances of the noteworthy class.
  module InstanceMethods
    # Generates the raw mentions to be loaded into the Mention objects
    # 
    # @return [Hash] a hash of all the mentions found of the object in question.
    def raw_mentions
      opts = self.options.clone
      attributes = opts.delete(:with)

      if opts[:geo]
        opts[:geo] = self.instance_eval("#{opts[:geo]}")
      end

      query = []
      attributes.each do |attr|
        query << self.instance_eval("#{attr}")
      end

      {
        :google_news => GovKit::SearchEngines::GoogleNews.search(query, opts),
        :google_blogs => GovKit::SearchEngines::GoogleBlog.search(query, opts),
#        :technorati => GovKit::SearchEngines::Technorati.search(query),
        :bing => GovKit::SearchEngines::Bing.search(query, opts)
      }
    end
  end
end
