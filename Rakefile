require 'rubygems'
require 'rake'
require(File.join(File.dirname(__FILE__), 'lib/zafu/info'))

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.version = Zafu::VERSION
    gem.name = 'zafu'
    gem.summary = %Q{Provides a powerful templating language based on xhtml for rails}
    gem.description = %Q{Provides a powerful templating language based on xhtml for rails}
    gem.email = "gaspard@teti.ch"
    gem.homepage = "http://zenadmin.org/zafu"
    gem.authors = ["Gaspard Bucher"]
    gem.add_development_dependency "shoulda", ">= 0"
    gem.add_development_dependency "yamltest", ">= 0.5.0"
    gem.add_dependency "rubyless", ">= 0.7.0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "zafu #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
