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

  # This class exists in order to run its insert method while
  # Rails is loading.
  # This then adds GovKit::ActsAsNoteworthy to ActiveRecord::Base.
  # See http://api.rubyonrails.org/classes/Rails/Railtie.html
  class Railtie
    def self.insert
      ActiveRecord::Base.send(:include, GovKit::ActsAsNoteworthy)
    end
  end
end
