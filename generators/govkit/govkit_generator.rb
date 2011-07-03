class GovkitGenerator < Rails::Generator::Base

  def initialize(*runtime_args)
    super
  end

  def manifest
    record do |m|
      m.directory File.join('config', 'initializers')
      m.template 'govkit.rb',   File.join('config', 'initializers', 'govkit.rb')
      m.directory File.join('app', 'models')
      m.template 'mention.rb',  File.join('app', 'models', 'mention.rb')
      m.directory File.join('db', 'migrate')
      m.template 'create_mentions.rb', File.join('db', 'migrate', 'create_mentions.rb')
    end
  end

  protected

  def banner
    %{Usage: #{$0} #{spec.name}\nCopies a config initializer to config/initializers/govkit.rb}
  end

end
