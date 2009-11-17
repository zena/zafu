begin
  dir = File.dirname(__FILE__)
  require "#{dir}/zafu/parser"
  require "#{dir}/zafu/compiler"
  require "#{dir}/zafu/template"
end

if defined?(ActionView)
  ActionView::Template.register_template_handler(:zafu, Zafu::Handler)
  ActionView::Template.register_template_handler(:html, Zafu::Handler)
end
