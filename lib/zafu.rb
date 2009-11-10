require 'zafu/parser'
require 'zafu/template'

ActionView::Template.register_template_handler(:zafu, Zafu::Handler)
ActionView::Template.register_template_handler(:html, Zafu::Handler)
