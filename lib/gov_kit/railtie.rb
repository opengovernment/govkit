require 'govkit'

module GovKit
  if defined? Rails::Railtie
    require 'rails'
    class Railtie < Rails::Railtie
      initializer 'govkit.insert_into_active_record' do
        ActiveSupport.on_load :active_record do
          GovKit::Railtie.insert
        end
      end
    end
  end

  class Railtie
    def self.insert
      ActiveRecord::Base.send(:include, GovKit::ActsAsNoteworthy)
    end
  end
end
