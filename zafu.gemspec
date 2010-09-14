# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{zafu}
  s.version = "0.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gaspard Bucher"]
  s.date = %q{2010-09-14}
  s.description = %q{Provides a powerful templating language based on xhtml for rails}
  s.email = %q{gaspard@teti.ch}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "History.txt",
     "README.rdoc",
     "Rakefile",
     "lib/zafu.rb",
     "lib/zafu/all.rb",
     "lib/zafu/compiler.rb",
     "lib/zafu/controller_methods.rb",
     "lib/zafu/handler.rb",
     "lib/zafu/info.rb",
     "lib/zafu/markup.rb",
     "lib/zafu/mock_helper.rb",
     "lib/zafu/node_context.rb",
     "lib/zafu/ordered_hash.rb",
     "lib/zafu/parser.rb",
     "lib/zafu/parsing_rules.rb",
     "lib/zafu/process/ajax.rb",
     "lib/zafu/process/conditional.rb",
     "lib/zafu/process/context.rb",
     "lib/zafu/process/forms.rb",
     "lib/zafu/process/html.rb",
     "lib/zafu/process/ruby_less_processing.rb",
     "lib/zafu/template.rb",
     "lib/zafu/test_helper.rb",
     "lib/zafu/view_methods.rb",
     "rails/init.rb",
     "script/console",
     "script/destroy",
     "script/generate",
     "test/markup_test.rb",
     "test/mock/classes.rb",
     "test/mock/core_ext.rb",
     "test/mock/params.rb",
     "test/mock/process.rb",
     "test/mock/test_compiler.rb",
     "test/node_context_test.rb",
     "test/ordered_hash_test.rb",
     "test/ruby_less_test.rb",
     "test/test_helper.rb",
     "test/zafu/ajax.yml",
     "test/zafu/asset.yml",
     "test/zafu/basic.yml",
     "test/zafu/markup.yml",
     "test/zafu/meta.yml",
     "test/zafu/security.yml",
     "test/zafu_test.rb",
     "zafu.gemspec"
  ]
  s.homepage = %q{http://zenadmin.org/zafu}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Provides a powerful templating language based on xhtml for rails}
  s.test_files = [
    "test/markup_test.rb",
     "test/mock/classes.rb",
     "test/mock/core_ext.rb",
     "test/mock/params.rb",
     "test/mock/process.rb",
     "test/mock/test_compiler.rb",
     "test/node_context_test.rb",
     "test/ordered_hash_test.rb",
     "test/ruby_less_test.rb",
     "test/test_helper.rb",
     "test/zafu_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<yamltest>, [">= 0.5.0"])
      s.add_runtime_dependency(%q<rubyless>, [">= 0.7.0"])
    else
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<yamltest>, [">= 0.5.0"])
      s.add_dependency(%q<rubyless>, [">= 0.7.0"])
    end
  else
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<yamltest>, [">= 0.5.0"])
    s.add_dependency(%q<rubyless>, [">= 0.7.0"])
  end
end

