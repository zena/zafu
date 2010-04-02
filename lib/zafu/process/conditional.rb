module Zafu
  module Process
    # This module manages conditional rendering (if, else, elsif, case, when).
    module Conditional
      def r_if
        "<% if true -%>#{expand_with(:in_if => true)}<% end -%>"
      end

      def r_else
        return '' unless @context[:in_if]
        # We use 'elsif' just in case there are more then one 'else' clause
        out "<% elsif true -%>#{expand_with(:in_if => false)}" # do not propagate
      end
    end # Context
  end # Process
end # Zafu
