require 'rails/generators'

class GovkitGenerator < Rails::Generators::Base

  def initialize(*runtime_args)
    super
  end

  desc "Copies a config initializer to config/initializers/govkit.rb"

  source_root File.join(File.dirname(__FILE__), 'templates')

  def copy_initializer_file
    copy_file 'govkit.rb', File.join('config', 'initializers', 'govkit.rb')
  end

end
