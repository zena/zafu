module Zafu
  class Handler < ActionView::TemplateHandler
    include ActionView::TemplateHandlers::Compilable

    class << self
      attr_accessor :options
    end

    self.options = {}
    cattr_accessor :erb_trim_mode
    self.erb_trim_mode = '-'

    def compile(template)
      puts "Compilation #{template} !"
      options = Zafu::Handler.options

      source = template.source
      Zafu::Template.new(source, options).src

      # src = ::ERB.new("<% __in_erb_template=true %>#{template.source}", nil, erb_trim_mode, '@output_buffer').src
      #
      # # Ruby 1.9 prepends an encoding to the source. However this is
      # # useless because you can only set an encoding on the first line
      # RUBY_VERSION >= '1.9' ? src.sub(/\A#coding:.*\n/, '') : src
    end
  end
end
