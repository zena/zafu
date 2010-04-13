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
          with_context(:node => node.move_to(var, node.klass.first)) do
            steal_and_eval_html_params_for(@markup, @params)
            @markup.set_id(node.dom_id) if need_dom_id?
            out @markup.wrap(expand_with)
          end
          out "<% end -%>"
        end

        # We need to return true for Ajax 'make_form'
        true
      end

      def helper
        @context[:helper]
      end

      # Return true if we need to insert the dom id for this element. This method is overwritten in Ajax.
      def need_dom_id?
        false
      end

      # Return the node context for a given class (looks up into the hierarchy) or the
      # current node context if klass is nil.
      def node(klass = nil)
        return @context[:node] if !klass
        @context[:node].get(klass)
      end

      def base_class
        if node.will_be?(Node)
          Node
        elsif node.will_be?(Version)
          Version
        else
          node.klass
        end
      end

      # Expand with a new node context.
      def expand_with_finder(finder)
        klass = finder[:class]
        if klass.kind_of?(Array)
          do_list(finder)
        else
          do_var(finder)
        end
      end

      # Expand blocks in a new list context.
      # This method is overwriten in Ajax
      def do_list(finder)
        if finder[:nil]
          out "<% if #{var} = #{finder[:method]} -%>"
          open_node_context(finder, :node => node.move_to(var, finder[:class])) do
            out @markup.wrap(expand_with(:in_if => true))
          end
          out "<% end -%>"
        else
          out "<% #{var} = #{finder[:method]} -%>"
          open_node_context(finder, :node => node.move_to(var, finder[:class])) do
            out @markup.wrap(expand_with)
          end
        end
      end

      # Expand blocks in a new var context.
      def do_var(finder)
        out "<% #{var} = #{finder[:method]} -%>"
        open_node_context(finder, :node => node.move_to(var, finder[:class])) do
          out @markup.wrap(expand_with)
        end
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

      # This method is called when we enter a new node context
      def node_context_vars(finder)
        # do nothing (this is a hook for other modules like QueryBuilder and RubyLess)
        {}
      end

      # Declare a variable that can be used later in the compilation. This method
      # returns the variable name to use.
      def set_var(var_list, var_name)
        var_name = var_name.to_sym
        out parser_error("'#{var_name}' already defined.") if @context[var_name] || var_list[var_name]
        var_list[var_name] = "_z#{var_name}"
      end

      # Change context for a given scope.
      def with_context(cont)
        raise "Block missing" unless block_given?
        cont_bak = @context.dup
          @context.merge!(cont)
          res = yield
        @context = cont_bak
        res
      end

      # This should be called when we enter a new node context so that the proper hooks are
      # triggered (insertion of contextual variables).
      def open_node_context(finder, cont = {})
        sub_context = node_context_vars(finder).merge(cont)

        with_context(sub_context) do
          yield
        end
      end
    end # Context
  end # Process
end # Zafu
