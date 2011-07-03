require 'rails/generators'

# Generator to setup rails app for using GovKit
class GovkitGenerator < Rails::Generators::Base

  def initialize(*runtime_args)
    super
  end

  desc "Copies files necessary to use govkit"

  source_root File.join(File.dirname(__FILE__), 'templates')
  
  # Copies the files necessary to use govkit (initializer, migrations, and models)
  def copy_initializer_file
    copy_file 'govkit.rb', File.join('config', 'initializers', 'govkit.rb')
    copy_file 'mention.rb', File.join('app', 'models', 'mention.rb')
    copy_file 'create_mentions.rb', File.join('db', 'migrate', "#{ Time.now.utc.strftime "%Y%m%d%H%M%S" }create_mentions.rb")
  end

end
