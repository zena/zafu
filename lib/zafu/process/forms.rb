module Zafu
  module Process
    module Forms
      def self.included(base)
        base.expander :make_form
      end

      def r_form
        form_for do |f|
          # Render error messages tag
          form_error_messages(f)

          # Render hidden fields
          form_hidden_fields(f)

          # Render form elements
          out expand_with(:form_helper => f)
        end
      end

      private
        def make_form
          return nil unless @context[:make_form]

          if method == 'each'
            r_form
          else
            nil
          end
        end

        # Return a form tag for the current node context class
        def form_for(node_context = self.node)
          klass = node.master_class(ActiveRecord::Base)
          out "<% form_for(#{node_context}) do |f| %>"
            yield('f')
          out "<% end -%>"
        end

        def form_hidden_fields(f)
        end

        def form_error_messages(f)
          out "<%= #{f}.error_messages %>"
        end

    end # Forms
  end # Process
end # Zafu
