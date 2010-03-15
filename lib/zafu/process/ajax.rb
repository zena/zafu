module Zafu
  module Process
    module Ajax

      # Store a context as a sub-template that can be used in ajax calls
      def r_block

        # 1. store template
        store_block(self)
        out expand_with
      end


      private
        def store_block(block)
          # Save current rendering information (id, html_tag_done, html_tag_params)
          markup_bak = block.markup.dup

          # Creatae new node context
          node_context = node.as_main

          # Change rendering context
          block.markup.done = false
          block.markup.set_id(node.dom_id) # "<%= dom_id(#{node}) %>"
        end

        template = expand_block(self, :)

        if @context[:block] == self
          # called from self (storing template)
          @context.reject! do |k,v|
            # FIXME: reject all stored elements in a  better way then this
            k.kind_of?(String) && k =~ /\ANode_\w/
          end
          @markup.done = false
          @markup.params.merge!(:id=>erb_dom_id)
          @context[:scope_node] = node if @context[:scope_node]
          out expand_with(:node => node)
          if @method == 'drop' && !@context[:make_form]
            out drop_javascript
          end
        else
          if parent.method == 'each' && @method == parent.single_child_method
            # use parent as block
            # FIXME: will not work with block as distant target...
            # do nothing
          else
            @markup.tag ||= 'div'
            new_dom_scope

            unless @context[:make_form]
              # STORE TEMPLATE ========

              context_bak = @context.dup # avoid side effects when rendering the same block
              ignore_list = @method == 'block' ? ['form'] : [] # do not show the form in the normal template of a block
              template    = expand_block(self, :block=>self, :list=>false, :saved_template=>true, :ignore => ignore_list)
              @context    = context_bak
              @result     = ''
              out helper.save_erb_to_url(template, template_url)

              # STORE FORM ============
              if edit = descendant('edit')
                publish_after_save = (edit.params[:publish] == 'true')
                if form = descendant('form')
                  # USE BLOCK FORM ========
                  form_text = expand_block(form, :saved_template=>true, :publish_after_save => publish_after_save)
                else
                  # MAKE A FORM FROM BLOCK ========
                  form = self.dup
                  form.method = 'form'
                  form_text = expand_block(form, :make_form => true, :list => false, :saved_template => true, :publish_after_save => publish_after_save)
                end
                out helper.save_erb_to_url(form_text, form_url)
              end
            end

            # RENDER
            @markup.done = false
            @markup.params.merge!(:id=>erb_dom_id)
          end

          out expand_with
          if @method == 'drop' && !@context[:make_form]
            out drop_javascript
          end
        end
      end
    end
  end
end