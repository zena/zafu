module Zafu
  class Template
    def initialize(template, src_helper, compilation_helper)
      @template = template
      @erb = Compiler.new_with_url(@template.path, :helper => src_helper).render(compilation_helper.zafu_context.merge(:helper => compilation_helper))
    end

    def src
      src = ::ERB.new("<% __in_erb_template=true %>#{@erb}", nil, '-', '@output_buffer').src

      # Ruby 1.9 prepends an encoding to the source. However this is
      # useless because you can only set an encoding on the first line
      RUBY_VERSION >= '1.9' ? src.sub(/\A#coding:.*\n/, '') : src
    end
  end
end