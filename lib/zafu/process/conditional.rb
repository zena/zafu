module Zafu
  module Process
    # This module manages conditional rendering (if, else, elsif, case, when).
    module Conditional
      def r_if(cond = nil)
        cond ||= get_attribute_or_eval(false)
        return parser_error("condition error") unless cond
        expand_if(cond)
      end

      def r_case
        r_if('false')
      end

      def r_else
        r_elsif('true')
      end

      def r_when
        r_elsif
      end

      def r_elsif(cond = nil)
        return '' unless @context[:in_if]
        cond ||= get_attribute_or_eval(false)
        return parser_error("condition error") unless cond

        res = expand_with(:in_if => false, :markup => nil)

        # We use 'elsif' just in case there are more then one 'else' clause
        if markup = @context[:markup]
          @markup.tag ||= markup.tag
          @markup.steal_html_params_from(@params)
          markup.params.each do |k, v|
            next if @markup.params[k]
            @markup.set_param(k, v)
          end

          markup.dyn_params.each do |k, v|
            next if @markup.params[k] || @markup.dyn_params[k]
            @markup.set_dyn_param(k, v)
          end

          out "<% elsif #{cond} -%>#{@markup.wrap(res)}" # do not propagate
        else
          @markup.done = true # never wrap else/elsif clause
          out "<% elsif #{cond} -%>#{res}" # do not propagate
        end
      end

      # Expand blocks with conditional enabled (else, elsif, etc).
      def expand_if(condition, new_node_context = self.node, alt_markup = @markup)
        res = ""
        res << "<% if #{condition} -%>"
        res << @markup.wrap(expand_with(:node => new_node_context))
        res << expand_with(:in_if => true, :only => %w{else elsif when}, :markup => alt_markup)
        res << "<% end -%>"
        res
      end
    end # Context
  end # Process
end # Zafu
