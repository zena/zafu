module Zafu
  module Process
    # This module manages the change of contexts by opening (each) or moving into the NodeContext.
    # The '@context' holds many information on the current compilation environment. Inside this
    # context, the "node" context holds information on the type of "this" (first responder).
    module Context
      def r_each
        if node.klass.kind_of?(Array)
          out "<% #{node}.each do |#{var}| -%>"
          out render_html_tag(expand_with_node(var, node.klass.first))
          out "<% end -%>"
        end
      end

      def helper
        @context[:helper]
      end

      # Return the node context for a given class (looks up into the hierarchy) or the
      # current node context if klass is nil.
      def node(klass = nil)
        return @context[:node] if !klass
        @context[:node].get(klass)
      end

      def expand_with_node(name, klass)
        expand_with(:node => @context[:node].move_to(name, klass))
      end

      # def context_with_node(name, klass)
      #   context = @context.dup
      #   context[:node] = context[:node].move_to(name, klass)
      # end

      def var
        return @var if @var
        if node.name =~ /^var(\d+)$/
          @var = "var#{$1.to_i + 1}"
        else
          @var = "var1"
        end
      end
    end # Context
  end # Process
end # Zafu
