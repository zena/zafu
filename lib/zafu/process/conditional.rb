module Zafu
  module Process
    # This module manages conditional rendering (if, else, elsif, case, when).
    module Conditional
      def r_if
        "<% if true -%>#{expand_with(:in_if => true)}<% end -%>"
      end

      def r_else
        return nil unless @context[:in_if]
        # We use 'elsif' just in case there are more then one 'else' clause
        out "<% elsif true -%>#{expand_with(:in_if => false)}" # do not propagate
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
