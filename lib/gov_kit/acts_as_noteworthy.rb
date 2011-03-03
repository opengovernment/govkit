module GovKit::ActsAsNoteworthy

  def self.included(base)
    base.extend ActMethods
  end

  module ActMethods
    def acts_as_noteworthy(options={})
      options[:keywords] ||= []

      class_inheritable_accessor :options
      self.options = options

      unless included_modules.include? InstanceMethods
        instance_eval do
          has_many :mentions, :as => :owner

          with_options :as => :owner, :class_name => "Mention" do |c|
            c.has_many :google_news_mentions, :conditions => {:search_source => "Google News"}, :order => 'date desc'
            c.has_many :google_blog_mentions, :conditions => {:search_source => "Google Blogs"}, :order => 'date desc'
            c.has_many :technorati_mentions, :conditions => {:search_source => "Technorati"}, :order => 'date desc'
          end
        end

        extend ClassMethods
        include InstanceMethods
      end
    end
  end

  module ClassMethods
  end

  module InstanceMethods

    def raw_mentions
      params = self.options[:keywords].clone
      attributes = self.options[:with].clone

      attributes.each do |attr|
        params << self.instance_eval("#{attr}")
      end
      {
        :google_news => GovKit::SearchEngines::GoogleNews.search(params),
        :google_blogs => GovKit::SearchEngines::GoogleBlog.search(params),
        :technorati => GovKit::SearchEngines::Technorati.search(params)
      }
    end
  end
end
