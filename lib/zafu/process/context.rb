module Zafu
  module Process
    module Context
      def r_each
        if node_class.kind_of?(Array)
          out "<% #{node}.each do |#{var}| -%>"
          out render_html_tag(expand_with(:node => var, :class => node_class.first))
          out "<% end -%>"
        end
      end

      def helper
        @context[:helper]
      end

      def node_class
        @context[:class]
      end

      def node
        @context[:node]
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
