require 'rubyless'

module Zafu
  module Process
    module RubyLess
      include ::RubyLess::SafeClass
      # Actual method resolution. The lookup first starts in the current helper. If nothing is found there, it
      # searches inside a 'helpers' module and finally looks into the current node_context.
      # If nothing is found at this stage, we prepend the method with the current node and start over again.
      def safe_method_type(signature)
        get_method_type(signature, false)
      end

      # Resolve unknown methods by using RubyLess in the current compilation context (the
      # translate method in RubyLess will call 'safe_method_type' in this module).
      def r_unknown
        if @method =~ /^[A-Z]/
          return rubyless_class_scope(@method)
        end

        if code = @method[/^\#\{(.+)\}$/, 1]
          @params[:eval] = $1
          r_show
        else
          rubyless_render(@method, @params)
        end
      rescue ::RubyLess::NoMethodError => err
        parser_error("#{err.error_message} <span class='type'>#{err.method_with_arguments}</span>", err.receiver_with_class)
      rescue ::RubyLess::Error => err
        parser_error(err.message)
      end

      # Print documentation on the current node type.
      def r_m
        if @params[:helper] == 'true'
          klass = helper.class
        else
          klass = node.klass
        end

        out "<div class='rubyless-m'><h3>Documentation for <b>#{klass}</b></h3>"
        out "<ul>"
        ::RubyLess::SafeClass.safe_methods_for(klass).each do |signature, opts|
          opts = opts.dup
          opts.delete(:method)
          if opts.keys == [:class]
            opts = opts[:class]
          end
          out "<li>#{signature.inspect} => #{opts.inspect}</li>"
        end
        out "</ul></div>"
      end

      # TEMPORARY METHOD DURING HACKING...
      def r_erb
        "<pre><%= @erb.gsub('<','&lt;').gsub('>','&gt;') %></pre>"
      end

      def rubyless_render(method, params)
        puts method_with_arguments(method, params).inspect
        rubyless_expand(::RubyLess.translate(method_with_arguments(method, params), self))
      end

      def rubyless_attr(val)
        ::RubyLess.translate_string(val, self)
      end

      private
        def get_method_type(signature, added_options = false)
          if type = node_context_from_signature(signature)
            # Resolve @page, @node
            type
          elsif type = safe_method_from(helper, signature)
            # Resolve template helper methods
            type
          elsif helper.respond_to?(:helpers) && type = safe_method_from(helper.helpers, signature)
            # Resolve by looking at the included helpers
            type
          elsif node && node.klass.kind_of?(Class) && type = safe_method_from(node.klass, signature)
            # Resolve node context methods (xxx.foo, xxx.bar)
            type.merge(:method => "#{node.name}.#{type[:method]}")
          elsif node && !added_options
            # Try prepending current node before arguments: link("foo") becomse link(var1, "foo")
            signature_with_node = signature.dup
            signature_with_node.insert(1, node.klass)
            if type = get_method_type(signature_with_node, added_options = true)
              type = type.merge(:prepend_args => ::RubyLess::TypedString.new(node.name, :class => node.klass))
              type
            else
              nil
            end
          else
            nil
          end
        end

        def method_with_arguments(method, params)
          hash_arguments = {}
          arguments = []
          keys = params.keys.map {|k| k.to_s}
          keys.sort.each do |k|
            if k.to_s =~ /\A_/
              arguments << params[k.to_sym]
            else
              hash_arguments[k.to_s] = params[k.to_sym]
            end
          end

          arguments += [hash_arguments] if hash_arguments != {}
          if arguments != [] && method[-1..-1] =~ /\w/
            "#{method}(#{arguments.inspect[1..-2]})"
          else
            method
          end
        end

        def rubyless_expand(res)
          if res.klass == String && @blocks.map {|b| b.kind_of?(String) ? nil : b.method}.compact.empty?
            out "<%= #{res} %>"
          elsif res.could_be_nil?
            out "<% if #{var} = #{res} -%>"
            out @markup.wrap(expand_with_node(var, res.klass))
            out "<% end -%>"
          else
            out "<% #{var} = #{res} -%>"
            out @markup.wrap(expand_with_node(var, res.klass))
          end
        end

        def rubyless_class_scope(class_name)
          # capital letter ==> class conditional
          klass = Module.const_get(class_name)
          if klass.ancestors.include?(node.klass)
            out "<% if #{node}.kind_of?(#{klass}) %>"
            out expand_with(:in_if => true)
            out "<% end -%>"
          else
            # render nothing: incompatible classes
            ''
          end
        rescue
          parser_error("Invalid class name '#{class_name}'")
        end

        # Find a class or behavior based on a name. The returned class should implement
        # 'safe_method_type'.
        def get_class(class_name)
          Module.const_get(class_name)
        rescue
          nil
        end

        # This is used to resolve '@node' as NodeContext with class Node, '@page' as first NodeContext
        # of type Page, etc.
        def node_context_from_signature(signature)
          return nil unless signature.size == 1
          ivar = signature.first
          return nil unless ivar[0..0] == '@'
          begin
            klass = Module.const_get(ivar[1..-1].capitalize)
            context = node(klass)
          rescue NameError
            return nil
          end
          {:class => context.klass, :method => context.name}
        end

        def safe_method_from(context, signature)
          if context.respond_to?(:safe_method_type)
            context.safe_method_type(signature)
          else
            ::RubyLess::SafeClass.safe_method_type_for(context, signature)
          end
        end

    end # RubyLess
  end # Process
end # Zafu