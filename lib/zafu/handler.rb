module Zafu
  class Handler < ActionView::TemplateHandler
    include ActionView::TemplateHandlers::Compilable

    def compile(template)
      @template = template
      helper   = Thread.current[:view]
      ast = Zafu::Template.new(template, self)
      context = helper.zafu_context.merge(:helper => helper)
      ast.to_ruby('@output_buffer', context)
    end

    def get_template_text(opts = {})
      if opts[:src] == @template.path && opts[:current_folder] == ''
        [@template.source, @template.path, nil]
      else
        # read template text from views...
        nil
      end
    end
  end
end

class ActionView::Template
  attr_reader :view
  def render_template_with_zafu(view, local_assigns = {})
    Thread.current[:view] = view
    render_template_without_zafu(view, local_assigns)
  end
  alias_method_chain :render_template, :zafu
end
