require 'rubyless'

module Zafu
  module Process
    module RubyLess
      include ::RubyLess::SafeClass

      def safe_method_type(signature)
        if context = context_from_signature(signature)
          context
        elsif helper.respond_to?(:safe_method_type) &&
           type = helper.safe_method_type(signature)
          type
        elsif helper.respond_to?(:helpers) &&
              type = ::RubyLess::SafeClass.safe_method_type_for(helper.helpers, signature)
          type
        elsif type = ::RubyLess::SafeClass.safe_method_type_for(node_class, signature)
          type.merge(:method => "#{node}.#{type[:method]}")
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

        # This is used to resolve 'node' as NodeContext with class Node, 'page' as first NodeContext
        # of type Page, etc.
        def context_from_signature(signature)
          return nil unless signature.size == 1
          ivar = signature.first
          return nil unless ivar[0..0] == '@'
          begin
            klass = Module.const_get(ivar[1..-1].capitalize)
            context = node_context(klass)
          rescue NameError
            return nil
          end
          {:class => context.klass, :method => context.name}
        end

    end # RubyLess
  end # Process
end # Zafu