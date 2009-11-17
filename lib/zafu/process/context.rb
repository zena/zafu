module Zafu
  module Process
    module Context
      def r_each
        if node_class.kind_of?(Array)
          out "<% #{node}.each do |#{var}| -%>"
          out render_html_tag(expand_with_node(var, node_class.first))
          out "<% end -%>"
        end
      end

      def helper
        @context[:helper]
      end

      def node_class
        @context[:node].klass
      end

      def node
        @context[:node].name
      end

      def node_context(klass)
        @context[:node].get(klass)
      end

      def expand_with_node(name, klass)
        expand_with(:node => context[:node].move_to(name, klass))
      end

      def context_with_node(name, klass)
        context = @context.dup
        context[:node] = context[:node].move_to(name, klass)
      end

      def var
        return @var if @var
        if node =~ /^var(\d+)$/
          @var = "var#{$1.to_i + 1}"
        else
          @var = "var1"
        end
      end
    end # Context
  end # Process
end # Zafu
