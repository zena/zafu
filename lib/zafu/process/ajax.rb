module Zafu
  module Process
    module Ajax
      def save_state
        super.merge(:@markup => @markup.dup)
      end


      # This method process a list and handles building the necessary templates for ajax 'add'.

      def do_list(finder)

        # Get the block responsible for rendering each elements in the list
        each_block = descendant('each')
        add_block  = descendant('add')
        form_block = descendant('form') || each_block
        edit_block = descendant('edit')


        # Should 'edit' and 'add' auto-publish ?
        publish_after_save = (form_block && form_block.params[:publish]) ||
                             (edit_block && edit_block.params[:publish])

        # class name for create form
        klass       = (add_block  &&  add_block.params[:klass]) ||
                      (form_block && form_block.params[:klass])

        if need_ajax?(each_block)
          # We need to build the templates for ajax rendering.

          # 1. Render inline
          #                                                                                                                 assign [] to var
          out "<% if (#{var} = #{finder[:method]}) || (#{node}.#{node.will_be?(Comment) ? "can_comment?" : "can_write?"} && #{var}=[]) -%>"
          # The list is not empty or we have enough rights to add new elements.
          set_dom_prefix

          # New node context.
          open_node_context(finder, :node => self.node.move_to(var, finder[:class])) do #, :need_link_id => form_block.need_link_id) do
            # Pagination count and other contextual variables exist here.

            # INLINE ==========
            # 'r_add' needs the form when rendering. Send with :form.
            out @markup.wrap(
              expand_with(
                :in_if              => false,
                :form               => form_block,
                :publish_after_save => publish_after_save,
                # Do not render the form block directly: let [add] do this.
                :ignore             => ['form'],
                :klass              => klass
              )
            )

            # Render 'else' clauses
            @markup.done = false
            out @markup.wrap(
              expand_with(
                :in_if => true,
                :only  => ['elsif', 'else']
              )
            )
          end
          out "<% end -%>"

          # 2. Save 'each' template
          store_block(each_block) #, :klass => klass) # do we need klass here ?

          # 3. Save 'form' template
          cont = {
            :saved_template     => form_url(node),
            :klass              => klass,
            :make_form          => each_block == form_block,
            :publish_after_save => publish_after_save,
          }

          store_block(form_block, cont)
        else
          super
        end

        # out @markup.wrap(expand_with(:node => node.move_to(var, finder[:class]), :in_if => true))


        #query = opts[:query]
        #
        #
        #if need_ajax?
        #  new_dom_scope
        #  # ajax, build template. We could merge the following code with 'r_block'.
        #
        #  # FORM ============
        #  if each_block != form_block
        #    form = expand_block(form_block, :klass => klass, :add=>add_block, :publish_after_save => publish_after_save, :saved_template => true)
        #  else
        #    form = expand_block(form_block, :klass => klass, :add=>add_block, :make_form=>true, :publish_after_save => publish_after_save, :saved_template => true)
        #  end
        #  out helper.save_erb_to_url(form, form_url)
        #else
        #  # no form, render, edit and add are not ajax
        #  if descendant('add') || descendant('add_document')
        #    out "<% if (#{list_var} = #{list_finder}) || (#{node}.#{node.will_be?(Comment) ? "can_comment?" : "can_write?"} && #{list_var}=[]) -%>"
        #  elsif list_finder != 'nil'
        #    out "<% if #{list_var} = #{list_finder} -%>"
        #  else
        #    out "<% if nil -%>"
        #  end
        #
        #
        #  out render_html_tag(expand_with(:list=>list_var, :in_if => false))
        #  out expand_with(:in_if=>true, :only=>['elsif', 'else'], :html_tag => @html_tag, :html_tag_params => @html_tag_params)
        #  out "<% end -%>"
        #end
      end

      # Store a context as a sub-template that can be used in ajax calls
      def r_block
        # Since we are using ajax, we will need this object to have an ID set.
        set_dom_prefix

        if @context[:block] == self
          # Storing template (called from within store_block)
          # Set id with the template's node context (<%= @node.zip %>)
          @markup.set_id(node.dom_id)
          expand_with
        else
          # 1. store template
          # will wrap with @markup
          store_block(self)

          # 2. render
          # Set id with the current node context (<%= var1.zip %>)
          @markup.set_id(node.dom_id)
          out expand_with
        end
      end

      def r_add
        return parser_error("Should not be called from within 'each'") if parent.method == 'each'
        return '' if @context[:make_form]

        if node.will_be?(Comment)
          out "<% if #{node.up(Node)}.can_comment? -%>"
        else
          out "<% if #{node.up(Node)}.can_write? -%>"
        end

        unless descendant('add_btn')
          # Add a descendant between self and blocks. ==> add( add_btn(blocks) )
          blocks = @blocks.dup
          @blocks = []
          add_btn = make(:void, :method=>'add_btn', :params=>@params.dup, :text=>'')
          add_btn.blocks = blocks
          remove_instance_variable(:@all_descendants)
        end

        if @context[:form]
          # ajax add
          @markup.set_id("#{node.dom_prefix}_add")
          @markup.append_param(:class, 'btn_add')

          if @params[:focus]
            focus = "$(\"#{node.dom_prefix}_#{@params[:focus]}\").focus();"
          else
            focus = "$(\"#{node.dom_prefix}_form_t\").focusFirstElement();"
          end

          # Expand 'add' block
          out @markup.wrap("#{expand_with(:onclick=>"[\"#{node.dom_prefix}_add\", \"#{node.dom_prefix}_form\"].each(Element.toggle);#{focus}return false;")}")

          # New object to render form
          new_node = node.move_to("#{var}_new", node.klass)

          if new_node.will_be?(Node)
            # FIXME: BUG if we set <r:form klass='Post'/> the user cannot select class with menu...

            # FIXME: inspect '@context[:form]' to see if it contains v_klass ?
            out "<% if #{new_node} = secure(Node) { Node.new_from_class('#{new_node.klass}') } -%>"
          else
            out "<% if #{new_node} = #{new_node.klass}.new -%>"
          end

          form_block = @context[:form]

          # Expand (inline) 'form' block
          out expand_block(form_block,
            # Needed in form to be able to return the result
            :template_url => template_url(node),
            # ??
            :in_add    => true,
            # ??
            :add       => self,
            # Transform 'each' block into a form
            :make_form => form_block.method == 'each',
            # Node context = new node
            :node      => new_node
          )
          out "<% end -%>"
        else
          # no ajax
          @markup.append_param(:class, 'btn_add') if @markup.tag
          out @markup.wrap(expand_with)
        end
        out "<% end -%>"
      end

      def r_add_btn
        default = node.will_be?(Comment) ? _("btn_add_comment") : _("btn_add")

        out "<a href='#' onclick='#{@context[:onclick]}'>#{text_for_link(default)}</a>"
      end

      def r_each
        if @context[:saved_template]
          # render to start a saved template
          options = form_options
          @markup.set_id(options[:id]) if options[:id]
          @markup.set_param(:style, options[:style]) if options[:style]

          out @markup.wrap(expand_with)
        else
          super
        end
      end

      # Return true if we need to insert the dom id for this element. This method is overwritten in Ajax.
      def need_dom_id?
        @context[:form]
      end

      # Set a unique DOM prefix to build unique ids in the page.
      def set_dom_prefix
        @name ||= unique_name
        node.dom_prefix = @name
      end

      # Unique template_url, ending with dom_id
      def template_url(node)
        "#{root.options[:root][1..-1]}/#{node.dom_prefix}"
      end

      def form_url(node)
        template_url(node) + '_form'
      end

      # Return a different name on each call
      def unique_name
        base = @name || @context[:name] || 'list'
        root.get_unique_name(base, base == @name).gsub(/[^\d\w\/]/,'_')
      end

      def get_unique_name(key, own_id = false)
        @next_name_index ||= {}
        if @next_name_index[key]
          @next_name_index[key] += 1
          key + @next_name_index[key].to_s
        elsif own_id
          @next_name_index[key] = 0
          key
        else
          @next_name_index[key] = 1
          key + '1'
        end
      end



      private
        def store_block(block, cont = {})
          cont = @context.merge(cont)

          # Create new node context
          node = cont[:node].as_main(ActiveRecord::Base)
          node.dom_prefix = @name

          cont[:template_url] = template_url(node)
          cont[:node]  = node
          cont[:block] = block
          cont[:saved_template] ||= cont[:template_url]

          template = expand_block(block, cont)

          out helper.save_erb_to_url(template, cont[:saved_template])
        end

        def need_ajax?(each_block)
          return false unless each_block
          # Inline editable
          each_block.descendant('edit') ||
          # Ajax add
          descendant('add') ||
          # List is reloaded from the 'add_document' popup
          descendant('add_document') ||
          # We use 'each' as block to render swap
          (descendant('swap') && descendant('swap').parent.method != 'block') ||
          # We use 'each' as block instead of the declared 'block' or 'drop'
          ['block', 'drop'].include?(each_block.single_child_method)
        end

        #template = expand_block(self, :)
        #
        #if @context[:block] == self
        #  # called from self (storing template)
        #  @context.reject! do |k,v|
        #    # FIXME: reject all stored elements in a  better way then this
        #    k.kind_of?(String) && k =~ /\ANode_\w/
        #  end
        #  @markup.done = false
        #  @markup.params.merge!(:id=>node.dom_id)
        #  @context[:scope_node] = node if @context[:scope_node]
        #  out expand_with(:node => node)
        #  if @method == 'drop' && !@context[:make_form]
        #    out drop_javascript
        #  end
        #else
        #  if parent.method == 'each' && @method == parent.single_child_method
        #    # use parent as block
        #    # FIXME: will not work with block as distant target...
        #    # do nothing
        #  else
        #    @markup.tag ||= 'div'
        #    new_dom_scope
        #
        #    unless @context[:make_form]
        #      # STORE TEMPLATE ========
        #
        #      context_bak = @context.dup # avoid side effects when rendering the same block
        #      ignore_list = @method == 'block' ? ['form'] : [] # do not show the form in the normal template of a block
        #      template    = expand_block(self, :block=>self, :list=>false, :saved_template=>true, :ignore => ignore_list)
        #      @context    = context_bak
        #      @result     = ''
        #      out helper.save_erb_to_url(template, template_url)
        #
        #      # STORE FORM ============
        #      if edit = descendant('edit')
        #        publish_after_save = (edit.params[:publish] == 'true')
        #        if form = descendant('form')
        #          # USE BLOCK FORM ========
        #          form_text = expand_block(form, :saved_template=>true, :publish_after_save => publish_after_save)
        #        else
        #          # MAKE A FORM FROM BLOCK ========
        #          form = self.dup
        #          form.method = 'form'
        #          form_text = expand_block(form, :make_form => true, :list => false, :saved_template => true, :publish_after_save => publish_after_save)
        #        end
        #        out helper.save_erb_to_url(form_text, form_url)
        #      end
        #    end
        #
        #    # RENDER
        #    @markup.done = false
        #    @markup.params.merge!(:id=>node.dom_id)
        #  end
        #
        #  out expand_with
        #  if @method == 'drop' && !@context[:make_form]
        #    out drop_javascript
        #  end
        #end

    end
  end
end