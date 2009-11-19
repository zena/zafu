# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{zafu}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gaspard Bucher"]
  s.date = %q{2009-11-18}
  s.description = %q{Provides a powerful templating language based on xhtml for rails.}
  s.email = %q{gaspard@teti.ch}
  s.extra_rdoc_files = ["History.txt", "README.rdoc"]
  s.files = [".gitignore", "History.txt", "README.rdoc", "Rakefile", "lib/zafu.rb", "lib/zafu/compiler.rb", "lib/zafu/controller_methods.rb", "lib/zafu/handler.rb", "lib/zafu/helper.rb", "lib/zafu/info.rb", "lib/zafu/mock_helper.rb", "lib/zafu/node_context.rb", "lib/zafu/parser.rb", "lib/zafu/parsing_rules.rb", "lib/zafu/process/context.rb", "lib/zafu/process/html.rb", "lib/zafu/process/ruby_less.rb", "lib/zafu/template.rb", "lib/zafu/test_helper.rb", "rails/init.rb", "script/console", "script/destroy", "script/generate", "test/.DS_Store", "test/node_context_test.rb", "test/test_helper.rb", "test/test_zafu.rb", "zafu-0.0.1.gem", "zafu.gemspec"]
  s.homepage = %q{http://zenadmin.org/zafu}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{zafu}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Provides a powerful templating language based on xhtml for rails}
  s.test_files = ["test/test_helper.rb", "test/test_zafu.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rubyless>, [">= 0.4.0"])
      s.add_development_dependency(%q<bones>, [">= 2.5.1"])
      s.add_development_dependency(%q<shoulda>, [">= 2.10.2"])
    else
      s.add_dependency(%q<rubyless>, [">= 0.4.0"])
      s.add_dependency(%q<bones>, [">= 2.5.1"])
      s.add_dependency(%q<shoulda>, [">= 2.10.2"])
    end
  else
    s.add_dependency(%q<rubyless>, [">= 0.4.0"])
    s.add_dependency(%q<bones>, [">= 2.5.1"])
    s.add_dependency(%q<shoulda>, [">= 2.10.2"])
  end
end
