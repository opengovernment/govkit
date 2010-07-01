module GovKit::ActsAsCiteable

  def self.included(base)
    base.extend ActMethods
  end

  module ActMethods
    def acts_as_citeable(options={})
      options[:keywords] ||= []

      class_inheritable_accessor :options
      self.options = options

      unless included_modules.include? InstanceMethods
        extend ClassMethods
        include InstanceMethods
      end
    end
  end

  module ClassMethods
  end

  module InstanceMethods

    def raw_citations
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
