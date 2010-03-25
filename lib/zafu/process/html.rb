module Zafu
  module Process
    module HTML
      attr_accessor :html_tag, :html_tag_params, :name, :sub_do

      # Replace the 'original' element in the included template with our new version.
      def replace_with(new_obj)
        super
        html_tag_params    = new_obj.html_tag_params
        [:class, :id].each do |sym|
          html_tag_params[sym] = new_obj.params[sym] if new_obj.params.include?(sym)
        end
        @markup.tag = new_obj.html_tag || @markup.tag
        @markup.params.merge!(html_tag_params)
        if new_obj.params[:method]
          @method   = new_obj.params[:method] if new_obj.params[:method]
        elsif new_obj.sub_do
          @method = 'void'
        end
      end

      # Pass the caller's 'html_tag' and 'html_tag_params' to the included part.
      def include_part(obj)
        obj.html_tag = @markup.tag || obj.html_tag
        obj.html_tag_params = !@markup.params.empty? ? @markup.params : obj.html_tag_params
        @markup.tag = nil
        @markup.params = {}
        super(obj)
      end

      def empty?
        super && @markup.params == {} && @markup.tag.nil?
      end

      def before_process
        return unless super
        @markup.done = false
        unless @markup.tag
          if @markup.tag = @params.delete(:tag)
            @markup.params = {}
            [:id, :class].each do |k|
              next unless @params[k]
              @markup.params[k] = @params.delete(k)
            end
          end
        end
        # Translate dynamic params such as <tt>class='#{visitor.lang}'</tt> in the context
        # of the current parser
        @markup.compile_params(self)

        # [each] is run many times with different roles. Some of these change html_tag_params.
        @markup_bak = @markup.dup
        true
      end

      def after_process(text)
        res = @markup.wrap(super)
        @markup = @markup_bak
        res
      end

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

        src = @params[key]
        if src && src[0..0] != '/' && src[0..6] != 'http://'
          @params[key] = helper.send(:template_url_for_asset, :src => src, :base_path => @options[:base_path], :type => type)
        end

        expand_with
      end

      def r_form
        res   = "<#{@markup.tag}#{params_to_html(@params)}"
        @markup.done = true
        inner = expand_with
        if inner == ''
          res + "/>"
        else
          res + ">#{inner}"
        end
      end

      def r_select
        res   = "<#{@markup.tag}#{params_to_html(@params)}"
        @markup.done = true
        inner = expand_with
        if inner == ''
          res + "></#{@markup.tag}>"
        else
          res + ">#{inner}"
        end
      end

      def r_input
        res   = "<#{@markup.tag}#{params_to_html(@params)}"
        @markup.done = true
        inner = expand_with
        if inner == ''
          res + "/>"
        else
          res + ">#{inner}"
        end
      end

      def r_textarea
        res   = "<#{@markup.tag}#{params_to_html(@params)}"
        @markup.done = true
        inner = expand_with
        if inner == ''
          res + "/>"
        else
          res + ">#{inner}"
        end
      end
    end # HTML
  end # Process
end # Zafu