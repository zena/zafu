require 'rubyless'

module Zafu
  module Parser
    module RubyLessTags
      include ::RubyLess::SafeClass

      def safe_method_type(signature)
        if helper.respond_to?(:safe_method_type) &&
           type = helper.safe_method_type(signature)
          type
        elsif helper.respond_to?(:helpers) &&
              type = ::RubyLess::SafeClass.safe_method_type_for(helper.helpers, signature)
          type
        elsif node_class.respond_to?(:safe_method_type) &&
              type = node_class.safe_method_type(signature)
          type.merge(:method => "#{node}.#{type[:method]}")
        else
          nil
        end
      end

      def r_unknown
        arguments = {}
        params.each do |k, v|
          arguments[k] = String
        end
        signature = [@method]
        signature += arguments if arguments != {}

        if res = RubyLess.translate(@method, self)
          if res.klass == String
            out "<%= #{res} %>"
          elsif res.could_be_nil?
            out "<% if #{var} = #{res} -%>"
            expand_with(:node => var, :class => res.klass)
            out "<% end -%>"
          else
            out "<% #{var} = #{res} -%>"
            expand_with(:node => var, :class => res.klass)
          end
        else
          super
        end
      end
    end # RubyLessTags
  end # Parser
end # Zafu