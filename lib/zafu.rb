require 'zafu/parser'
require 'zafu/compiler'
require 'zafu/template'

if defined?(ActionView)
  ActionView::Template.register_template_handler(:zafu, Zafu::Handler)
  ActionView::Template.register_template_handler(:html, Zafu::Handler)
end

module Zafu
  def self.compile(text, src_helper = nil)
    Zafu::Template.new(text, src_helper)
  end
end
