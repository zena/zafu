module Zafu
  module Process
    module Ajax
      def save_state
        super.merge(:@markup => @markup.dup)
      end

      # Store a context as a sub-template that can be used in ajax calls
      def r_block
        # Since we are using ajax, we will need this object to have an ID set.
        @name ||= unique_name
        node.dom_prefix = @name

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

      # def r_add
      #   return parser_error("should not be called from within 'each'") if parent.method == 'each'
      #   return '' if @context[:make_form]
      #
      #   # why is node = @node (which we need) but we are supposed to have Comments ?
      #   # FIXME: during rewrite, replace 'node' by 'node(klass = node_class)' so the ugly lines below would be
      #   # if node.will_be?(Comment)
      #   #   out "<% if #{node(Node)}.can_comment? -%>"
      #   # Refs #198.
      #   if node.will_be?(Comment)
      #     out "<% if #{node}.can_comment? -%>"
      #   else
      #     out "<% if #{node}.can_write? -%>"
      #   end
      #
      #   unless descendant('add_btn')
      #     # add a descendant between self and blocks.
      #     blocks = @blocks.dup
      #     @blocks = []
      #     add_btn = make(:void, :method=>'add_btn', :params=>@params.dup, :text=>'')
      #     add_btn.blocks = blocks
      #     remove_instance_variable(:@all_descendants)
      #   end
      #
      #   if @context[:form] && @context[:dom_prefix]
      #     # ajax add
      #
      #     @html_tag_params.merge!(:id => "#{erb_dom_id}_add")
      #     @html_tag_params[:class] ||= 'btn_add'
      #     if @params[:focus]
      #       focus = "$(\"#{erb_dom_id}_#{@params[:focus]}\").focus();"
      #     else
      #       focus = "$(\"#{erb_dom_id}_form_t\").focusFirstElement();"
      #     end
      #
      #     out render_html_tag("#{expand_with(:onclick=>"[\"#{erb_dom_id}_add\", \"#{erb_dom_id}_form\"].each(Element.toggle);#{focus}return false;")}")
      #
      #     if node.will_be?(Node)
      #       # FIXME: BUG if we set <r:form klass='Post'/> the user cannot select class with menu...
      #       klass = @context[:klass] || 'Node'
      #       # FIXME: inspect '@context[:form]' to see if it contains v_klass ?
      #       out "<% if #{var}_new = secure(Node) { Node.new_from_class(#{klass.inspect}) } -%>"
      #     else
      #       out "<% if #{var}_new = #{node_class}.new -%>"
      #     end
      #
      #     if @context[:form].method == 'form'
      #       out expand_block(@context[:form], :in_add => true, :no_ignore => ['form'], :add=>self, :node => "#{var}_new", :parent_node => node, :klass => klass, :publish_after_save => auto_publish_param)
      #     else
      #       # build form from 'each'
      #       out expand_block(@context[:form], :in_add => true, :no_ignore => ['form'], :add=>self, :make_form => true, :node => "#{var}_new", :parent_node => node, :klass => klass, :publish_after_save => auto_publish_param)
      #     end
      #     out "<% end -%>"
      #   else
      #     # no ajax
      #     @html_tag_params[:class] ||= 'btn_add' if @html_tag
      #     out render_html_tag(expand_with)
      #   end
      #   out "<% end -%>"
      #   @html_tag_done = true
      # end

      # Unique template_url, ending with dom_id
      def template_url
        "#{@options[:root]}/#{node.dom_prefix}"
      end

      def form_url
        template_url + '_form'
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
        def store_block(block)
          # Create new node context
          node = block.context[:node].as_main(ActiveRecord::Base)
          node.dom_prefix = @name

          template = expand_block(block, :template_url => block.template_url, :node => node, :block => block)

          out helper.save_erb_to_url(template, template_url)
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
        #  @markup.params.merge!(:id=>erb_dom_id)
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
        #    @markup.params.merge!(:id=>erb_dom_id)
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