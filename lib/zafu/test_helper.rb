module Zafu
  module TestHelper
    include ::RubyLess::SafeClass

    def zafu_erb(source, src_helper = self)
      Zafu.compile(source, src_helper).to_erb(compilation_context)
    end

    def zafu_render(source, src_helper = self)
      eval Zafu.compile(source, src_helper).to_ruby(compilation_context)
    end

    def compilation_context
      {:node => @node_context, :helper => self}
    end
  end
end