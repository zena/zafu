module Zafu
  class Handler < ActionView::TemplateHandler
    include ActionView::TemplateHandlers::Compilable

    def compile(template)
      @template = template
      @helper   = Thread.current[:view]
      Zafu::Template.new(template, self, @helper).src

      # src = ::ERB.new("<% __in_erb_template=true %>#{template.source}", nil, '-', '@output_buffer').src
      #
      # # Ruby 1.9 prepends an encoding to the source. However this is
      # # useless because you can only set an encoding on the first line
      # RUBY_VERSION >= '1.9' ? src.sub(/\A#coding:.*\n/, '') : src
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
