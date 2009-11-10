# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{zafu}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gaspard Bucher"]
  s.date = %q{2009-11-10}
  s.description = %q{Provides a powerful templating language based on xhtml for rails.}
  s.email = %q{gaspard@teti.ch}
  s.extra_rdoc_files = ["History.txt", "README.rdoc"]
  s.files = ["History.txt", "README.rdoc", "Rakefile", "lib/zafu.rb", "lib/zafu/handler.rb", "lib/zafu/info.rb", "lib/zafu/parser.rb", "lib/zafu/template.rb", "rails/init.rb", "script/console", "script/destroy", "script/generate", "test/test_helper.rb", "test/test_zafu.rb", "zafu-0.0.1.gem", "zafu.gemspec"]
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
      s.add_development_dependency(%q<bones>, [">= 2.5.1"])
    else
      s.add_dependency(%q<bones>, [">= 2.5.1"])
    end
  else
    s.add_dependency(%q<bones>, [">= 2.5.1"])
  end
end
