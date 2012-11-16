require 'rubygems'
require 'rake'
require 'rake/rdoctask'

begin
  require 'rspec/core/rake_task'
rescue LoadError
  begin
    gem 'rspec-rails', '>= 2.0.0'
    require 'rspec/core/rake_task'
  rescue LoadError
    puts "[govkit:] RSpec - or one of it's dependencies - is not available. Install it with: sudo gem install rspec-rails"
  end
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "govkit"
    gem.summary = %Q{Simple access to open government APIs around the web}
    gem.description = %Q{Govkit lets you quickly get encapsulated Ruby objects for common open government APIs. We're starting with Sunlight's Open States API and the Project Vote Smart API.}
    gem.email = "develop@opencongress.org"
    gem.homepage = "http://github.com/opengovernment/govkit"
    gem.authors = ["Participatory Politics Foundation", "Srinivas Aki", "Carl Tashian"]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end



begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :default => :spec

Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "govkit #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


if defined?(RSpec)
  desc 'Test the govkit plugin.'
  RSpec::Core::RakeTask.new('spec') do |t|
    t.rspec_opts = ["-c"]
  end

  desc 'Test the govkit plugin with specdoc formatting and colors'
  RSpec::Core::RakeTask.new('specdoc') do |t|
    t.rspec_opts = ["--format specdoc", "-c"]
  end

  desc "Run all examples with RCov"
  RSpec::Core::RakeTask.new('examples_with_rcov') do |t|
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec,Library']
  end
end

desc "Generate RSpec fixtures"
task :generate_rspec_fixtures do |t,args|
  if ENV['APIKEY'].nil?
    abort "Usage: APIKEY=12345... rake generate_rspec_fixtures"
  end

  { "/legislators/XXL123456/" => '401.response',
    "/metadata/ca/?apikey=#{ENV['APIKEY']}" => 'state.response',
    "/bills/ca/20092010/lower/AB%20667/?apikey=#{ENV['APIKEY']}" => 'bill.response',
    "/bills/?apikey=#{ENV['APIKEY']}&q=cooperatives" => 'bill_find.response',
    "/bills/?apikey=#{ENV['APIKEY']}&updated_since=2012-11-01&state=tx" => 'bill_query.response',
    "/legislators/CAL000088/?apikey=#{ENV['APIKEY']}" => 'legislator_find.response',
    "/legislators/CAL999999/?apikey=#{ENV['APIKEY']}" => '404.response',
    "/legislators/?apikey=#{ENV['APIKEY']}&state=ca" => 'legislator_query.response',
    "/legislators/?apikey=#{ENV['APIKEY']}&state=zz" => '404.response',
    "/committees/MDC000012/?apikey=#{ENV['APIKEY']}" => 'committee_find.response',
    "/committees/?apikey=#{ENV['APIKEY']}&state=md&chamber=upper" => 'committee_query.response',
  }.each do |path,basename|
    filepath = File.expand_path("../spec/fixtures/open_states/#{basename}", __FILE__)
    `curl -s -i -o #{filepath} "http://openstates.org/api/v1#{path}"`
  end
end
