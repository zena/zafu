module Zafu
  class Template
    def initialize(template, src_helper = nil)
      if template.kind_of?(String)
        @ast = Compiler.new(template)
      else
        @ast = Compiler.new_with_url(template.path, :helper => src_helper)
      end
    end

    def to_erb(context = {})
      @ast.process(context)
    end

    def to_ruby(context = {})
      src = ::ERB.new("<% __in_erb_template=true %>#{to_erb(context)}", nil, '-').src

      # Ruby 1.9 prepends an encoding to the source. However this is
      # useless because you can only set an encoding on the first line
      RUBY_VERSION >= '1.9' ? src.sub(/\A#coding:.*\n/, '') : src
    end
  end
end