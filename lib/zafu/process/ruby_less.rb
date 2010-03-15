require 'rubyless'

module Zafu
  module Process
    module RubyLess
      include ::RubyLess::SafeClass

      def safe_method_type(signature, added_options = false)
        if type = context_from_signature(signature)
          type
        elsif type = safe_method_from(helper, signature)
          type
        elsif helper.respond_to?(:helpers) && type = safe_method_from(helper.helpers, signature)
          type
        elsif node_class.kind_of?(Class) && type = safe_method_from(node_class, signature)
          type.merge(:method => "#{node.name}.#{type[:method]}")
        elsif !added_options
          # sigle method, try inserting current node
          signature_with_node = signature.dup
          signature_with_node.insert(1, node_class)
          if type = safe_method_type(signature_with_node, added_options = true)
            type = type.merge(:prepend_args => ::RubyLess::TypedString.new(node, :class => node_class))
            type
          else
            raise ::RubyLess::NoMethodError.new(nil, helper, signature)
          end
        elsif added_options
          nil
        else
          raise ::RubyLess::NoMethodError.new(nil, helper, signature)
        end
      end

      def r_unknown
        rubyless_expand(::RubyLess.translate(method_with_arguments, self))
      rescue ::RubyLess::NoMethodError => err
        parser_error("#{err.error_message} <span class='type'>#{err.method_with_arguments}</span>", err.receiver_with_class)
      rescue ::RubyLess::Error => err
        parser_error(err.message)
      end

      def r_m
        out "<div class='rubyless-m'><h3>Documentation for <b>#{node_class}</b></h3>"
        out "<ul>"
        ::RubyLess::SafeClass.safe_methods_for(node_class).each do |signature, opts|
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

      private
        def method_with_arguments
          hash_arguments = {}
          arguments = []
          keys = @params.keys.map {|k| k.to_s}
          keys.sort.each do |k|
            if k.to_s =~ /\A_/
              arguments << @params[k.to_sym]
            else
              hash_arguments[k.to_s] = @params[k.to_sym]
            end
          end

          arguments += [hash_arguments] if hash_arguments != {}
          if arguments != [] && @method[-1..-1] =~ /\w/
            "#{@method}(#{arguments.inspect[1..-2]})"
          else
            @method
          end
        end

        def rubyless_expand(res)
          if res.klass == String && @blocks.map {|b| b.kind_of?(String) ? nil : b.method}.compact.empty?
            out "<%= #{res} %>"
          elsif res.could_be_nil?
            out "<% if #{var} = #{res} -%>"
            out render_html_tag(expand_with_node(var, res.klass))
            out "<% end -%>"
          else
            out "<% #{var} = #{res} -%>"
            out render_html_tag(expand_with_node(var, res.klass))
          end
        end

        # This is used to resolve '@node' as NodeContext with class Node, '@page' as first NodeContext
        # of type Page, etc.
        def context_from_signature(signature)
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