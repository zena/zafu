require 'rubyless'

module Zafu
  module Parser
    module RubyLessTags
      include ::RubyLess::SafeClass

      def safe_method_type(signature)
        if signature == ['node']
          {:class => node_class, :method => node}
        elsif helper.respond_to?(:safe_method_type) &&
           type = helper.safe_method_type(signature)
          type
        elsif helper.respond_to?(:helpers) &&
              type = ::RubyLess::SafeClass.safe_method_type_for(helper.helpers, signature)
          type
        elsif type = ::RubyLess::SafeClass.safe_method_type_for(node_class, signature)
          type.merge(:method => "#{node}.#{type[:method]}")
        else
          nil
        end
      end

      def r_unknown
        rubyless_expand(RubyLess.translate(method_with_arguments, self))
      rescue
        super
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

          arguments += hash_arguments if hash_arguments != {}
          if arguments != []
            "#{@method}(#{arguments.inspect[1..-2]})"
          else
            @method
          end
        end

        def rubyless_expand(res)
          if res.klass == String
            out "<%= #{res} %>"
          elsif res.could_be_nil?
            out "<% if #{var} = #{res} -%>"
            out expand_with(:node => var, :class => res.klass)
            out "<% end -%>"
          else
            out "<% #{var} = #{res} -%>"
            out expand_with(:node => var, :class => res.klass)
          end
        end
    end # RubyLessTags
  end # Parser
end # Zafu