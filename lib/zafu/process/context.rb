module Zafu
  module Process
    # This module manages the change of contexts by opening (each) or moving into the NodeContext.
    # The '@context' holds many information on the current compilation environment. Inside this
    # context, the "node" context holds information on the type of "this" (first responder).
    module Context
      def r_each
        if node.klass.kind_of?(Array)
          if @params[:alt_class] || @params[:join]
            out "<% #{var}_max_index = #{node}.size - 1 -%>" if @params[:alt_reverse]
            out "<% #{node}.each_with_index do |#{var},#{var}_index| -%>"

            if join = @params[:join]
              join = ::RubyLess.translate_string(join, self)
              #if join_clause = @params[:join_if]
              #  set_stored(Node, 'prev', "#{var}_prev")
              #  cond = get_test_condition(var, :test=>join_clause)
              #  out "<%= #{var}_prev = #{node}[#{var}_index - 1]; (#{var}_index > 0 && #{cond}) ? #{join.inspect} : '' %>"
              #else
                out "<%= #{var}_index > 0 ? #{join} : '' %>"
              #end
            end

            if alt_class = @params[:alt_class]
              alt_class = ::RubyLess.translate_string(alt_class, self)
              alt_test = @params[:alt_reverse] == 'true' ? "(#{var}_max_index - #{var}_index) % 2 != 0" : "#{var}_index % 2 != 0"
              @markup.append_dyn_param(:class, "<%= #{alt_test} ? #{alt_class} : '' %>")
              @markup.tag ||= 'div'
            end
          else
            out "<% #{node}.each do |#{var}| -%>"
          end
          @context[:node] = @context[:node].move_to(var, node.klass.first)
            steal_and_eval_html_params_for(@markup, @params)
            out @markup.wrap(expand_with)
          @context[:node] = @context[:node].up
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
