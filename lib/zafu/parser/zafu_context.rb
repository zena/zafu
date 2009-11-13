module Zafu
  module Parser
    module ZafuContext
      def helper
        @context[:helper]
      end

      def node_class
        @context[:class]
      end

      def node
        @context[:node]
      end
    end
  end
end
