require 'rubygems'
require 'rake'
require 'rake/rdoctask'

begin
  require 'spec/rake/spectask'
rescue LoadError
  begin
    gem 'rspec-rails', '>= 1.0.0'
    require 'spec/rake/spectask'
  rescue LoadError
    puts "[govkit:] RSpec - or one of it's dependencies - is not available. Install it with: sudo gem install rspec-rails"
  end
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "govkit"
    gem.summary = %Q{Simple access to open government APIs around the web}
    gem.description = %Q{TODO: longer description of your gem}
    gem.email = "carl@ppolitics.org"
    gem.homepage = "http://github.com/opengovernment/govkit"
    gem.authors = ["Carl Tashian"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
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


if defined?(Spec)
  desc 'Test the govkit plugin.'
  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = ["-c"]
  end

  desc 'Test the govkit plugin with specdoc formatting and colors'
  Spec::Rake::SpecTask.new('specdoc') do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = ["--format specdoc", "-c"]
  end

  desc "Run all examples with RCov"
  Spec::Rake::SpecTask.new('examples_with_rcov') do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec,Library']
  end
end
