module Zafu
  module Process
    module HTML
      def self.included(base)
        base.wrap  :wrap_html
      end

      # Replace the 'original' element in the included template with our new version.
      def replace_with(new_obj)
        super
        # [self = original_element]. Replace @markup with content of the new_obj (<ul do='with'>...)
        if new_obj.markup.tag
          @markup.tag = new_obj.markup.tag
        end

        @markup.params.merge!(new_obj.markup.params)

        # We do not have to merge dyn_params since these are compiled before processing (and we are in
        # the pre-processor)

        if new_obj.params[:method]
          @method   = new_obj.params[:method]
        elsif new_obj.sub_do
          @method = 'void'
        end
      end

      # Pass the caller's 'markup' to the included part.
      def include_part(obj)
        if @markup.tag
          obj.markup = @markup.dup
        end
        @markup.tag = nil
        super(obj)
      end

      def empty?
        super && @markup.params == {} && @markup.tag.nil?
      end

      def compile_html_params
        @markup.done = false
        unless @markup.tag
          if @markup.tag = @params.delete(:tag)
            @markup.steal_html_params_from(@params)
          end
        end

        # Translate dynamic params such as <tt>class='#{visitor.lang}'</tt> in the context
        # of the current parser
        @markup.compile_params(self)

        # [each] is run many times with different roles. Some of these change html_tag_params.
      #  @markup_bak = @markup.dup
      end

      def wrap_html(text)
        compile_html_params
        @markup.wrap(text)
      end

      #def restore_markup
      #  # restore @markup
      #  @markup = @markup_bak
      #end

      def inspect
        @markup.done = false
        res = super
        if @markup.tag
          if res =~ /\A\[(\w+)(.*)\/\]\Z/m
            res = "[#{$1}#{$2}]<#{@markup.tag}/>[/#{$1}]"
          elsif res =~ /\A\[([^\]]+)\](.*)\[\/(\w+)\]\Z/m
            res = "[#{$1}]#{render_html_tag($2)}[/#{$3}]"
          end
        end
        res
      end

      def r_ignore
        @markup.done = true
        ''
      end

      alias r_ r_ignore

      def r_rename_asset
        return expand_with unless @markup.tag
        case @markup.tag
        when 'link'
          key = :href
          if @params[:rel].downcase == 'stylesheet'
            type = :stylesheet
          else
            type = :link
          end
        when 'style'
          @markup.done = true
          return expand_with.gsub(/url\(('|")(.*?)\1\)/) do
            if $2[0..6] == 'http://'
              $&
            else
              quote   = $1
              new_src = helper.send(:template_url_for_asset, :base_path=>@options[:base_path], :src => $2)
              "url(#{quote}#{new_src}#{quote})"
            end
          end
        else
          key = :src
          type = @markup.tag.to_sym
        end

        src = @params.delete(key)
        if src && src[0..6] != 'http://'
          @markup.params[key] = helper.send(:template_url_for_asset, :src => src, :base_path => @options[:base_path], :type => type)
        end

        @markup.steal_html_params_from(@params)

        expand_with
      end

      #def r_form
      #  res   = "<#{@markup.tag}#{params_to_html(@params)}"
      #  @markup.done = true
      #  inner = expand_with
      #  if inner == ''
      #    res + "/>"
      #  else
      #    res + ">#{inner}"
      #  end
      #end
      #
      #def r_select
      #  res   = "<#{@markup.tag}#{params_to_html(@params)}"
      #  @markup.done = true
      #  inner = expand_with
      #  if inner == ''
      #    res + "></#{@markup.tag}>"
      #  else
      #    res + ">#{inner}"
      #  end
      #end
      #
      #def r_input
      #  res   = "<#{@markup.tag}#{params_to_html(@params)}"
      #  @markup.done = true
      #  inner = expand_with
      #  if inner == ''
      #    res + "/>"
      #  else
      #    res + ">#{inner}"
      #  end
      #end
      #
      #def r_textarea
      #  res   = "<#{@markup.tag}#{params_to_html(@params)}"
      #  @markup.done = true
      #  inner = expand_with
      #  if inner == ''
      #    res + "/>"
      #  else
      #    res + ">#{inner}"
      #  end
      #end
    end # HTML
  end # Process
end # Zafu