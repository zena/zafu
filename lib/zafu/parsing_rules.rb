module Zafu
  module ParsingRules
    # The context informs the rendering element about the current Node, node class, existing ids, etc. The
    # context is inherited by sub-elements.
    attr_reader :context

    # The helper is used to connect the compiler to the world of the application (read/write templates, access traductions, etc)
    attr_reader :helper

    # The markup (of class Markup) holds information on the tag (<li>), tag attributes (.. class='foo') and
    # indentation information that should be used when rendered. This context is not inherited.
    attr_accessor :markup

    # This callback is run just after the block is initialized (Parser#initialize).
    def start(mode)
      # tag_context
      @markup = Markup.new(@options.delete(:html_tag))

      # html_tag
      @markup.params = @options.delete(:html_tag_params) # @html_tag_params

      # have we already wrapped the result with our tag ?
      @markup.done = false # @html_tag_done

      # end_tag is used to know when to close parsing in sub-do
      # Example:
      # <li do='each' do='images'>
      #   <ul>
      #     <li><r:link/></li> <!-- do not close outer LI now: @end_tag_count != 0 -->
      #   </ul>
      # </li> <!-- close outer LI now: @end_tag_count == 0 -->
      #
      @end_tag = @markup.tag || @options.delete(:end_tag) || "r:#{@method}"
      @end_tag_count  = 1

      # code indentation
      @markup.space_before = @options.delete(:space_before) # @space_before

      # form capture (input, select, textarea, form)
      # FIXME: what is this ???
      @options[:form] ||= true if @method == 'form'

      # puts "[#{@markup[:space_before]}(#{@method})#{@markup[:space_after]}]"
      if @params =~ /\A([^>]*?)do\s*=('|")([^\2]*?[^\\])\2([^>]*)\Z/
        # we have a sub 'do'
        @params = Markup.parse_params($1)
        @sub_do = $3 # this is used by replace_with (FIXME)

        opts = {:method=>$3, :params=>$4}

        # the matching zafu tag will be parsed by the last 'do', we must inform it to halt properly :
        opts[:end_tag] = @end_tag

        sub = make(:void, opts)
        @markup.space_after = sub.markup.space_after
        sub.markup.space_after = ""
      else
        @params = Markup.parse_params(@params)
      end

      # set name used for include/replace from html_tag if not allready set by superclass
      @name = @options[:name] || @params[:name] || @params[:id] || @markup.params[:id]

      if !@markup.tag && (@markup.tag = @params.delete(:tag))
        # Extract html tag parameters from @params
        @markup.steal_html_params_from(@params)
      end

      if @method == 'include'
        include_template
      elsif mode == :tag && !sub
        scan_tag
      elsif !sub
        enter(mode)
      end
    end

    def before_parse(text)
      text.gsub('<%', '&lt;%').gsub('%>', '%&gt;')
    end

    # scan rules
    def scan
      # puts "SCAN(#{@method}): [#{@text}]"
      if @text =~ /\A([^<]*?)(^ *|)</m
        flush $1
        eat $2
        if @text[1..1] == '/'
          store $2
          scan_close_tag
        elsif @text[0..3] == '<!--'
          scan_html_comment(:space_before=> $2)
        elsif @text[0..8] == '<![CDATA['
          flush '<![CDATA['
        else
          scan_tag(:space_before=> $2)
        end
      else
        # no more tags
        flush
      end
    end

    def scan_close_tag
      if @text =~ /\A<\/([^>]+)>( *\n+|)/m
        # puts "CLOSE:[#{$&}]}" # ztag
        # closing tag
        if $1 == @end_tag
          @end_tag_count -= 1
          if @end_tag_count == 0
            if @end_tag == 'script'
              flush $& # keep closing tag
            else
              eat $&
            end
            @markup.space_after = $2
            leave
          else
            # keep the tag (false alert)
            flush $&
          end
        elsif $1[0..1] == 'r:'
          # /rtag
          eat $&
          if $1 != @end_tag
            # error bad closing rtag
            store "<span class='parser_error'>#{$&.gsub('<', '&lt;').gsub('>','&gt;')} should be &lt;/#{@end_tag}&gt;</span>"
          end
          leave
        else
          # other html tag closing
          flush $&
        end
      else
        # error
        flush
      end
    end

    def scan_html_comment(opts={})
      if @text =~ /\A<!--\|(.*?)-->/m
        # zafu html escaped
        eat $&
        @text = opts[:space_before] + $1 + @text
      elsif @text =~ /\A<!--.*?-->/m
        # html comment
        flush $&
      else
        # error
        flush
      end
    end

    def scan_tag(opts={})
      # puts "TAG(#{@method}): [#{@text}]"
      if @text =~ /\A<r:([\w_]+)([^>]*?)(\/?)>/
        # puts "RTAG:#{$~.to_a.inspect}" # ztag
        eat $&
        opts.merge!(:method=>$1, :params=>$2)
        opts.merge!(:text=>'') if $3 != ''
        make(:void, opts)
      elsif @text =~ /\A<(\w+)([^>]*?)do\s*=('([^>]*?[^\\]|)'|"([^>]*?[^\\]|)")([^>]*?)(\/?)>/
        #puts "DO:#{$~.to_a.inspect}" # do tag
        eat $&
        opts.merge!(:method=>($4||$5), :html_tag=>$1, :html_tag_params=>$2, :params=>$6)
        opts.merge!(:text=>'') if $7 != ''
        make(:void, opts)
      elsif @options[:form] && @text =~ /\A<(input|select|textarea|form)([^>]*?)(\/?)>/
        eat $&
        method = $1 == 'form' ? 'form_tag' : $1 # <form> ==> r_form_tag, <r:form> ==> r_form
        opts.merge!(:method=>method, :params=>$2)
        opts.merge!(:text=>'') if $3 != ''
        opts.merge!(:end_tag=>'form') if method == 'form_tag'
        make(:void, opts)
      elsif @text =~ /\A<(\w+)([^>]*?)id\s*=('[^>]*?[^\\]'|"[^>]*?[^\\]")([^>]*?)(\/?)>/
        #puts "ID:#{$~.to_a.inspect}" # id tag
        eat $&
        opts.merge!(:method=>'void', :html_tag=>$1, :params=>{:id => $3[1..-2]}, :html_tag_params=>"#{$2}id=#{$3}#{$4}")
        opts.merge!(:text=>'') if $5 != ''
        make(:void, opts)
      elsif @end_tag && @text =~ /\A<#{@end_tag}([^>]*?)(\/?)>/
        #puts "SAME:#{$~.to_a.inspect}" # simple html tag same as end_tag
        flush $&
        @end_tag_count += 1 unless $2 == '/'
      elsif @text =~ /\A<(link|img|script)/
        #puts "HTML:[#{$&}]" # html
        make(:asset)
      elsif @text =~ /\A<style>/
        flush $&
        make(:style)
      elsif @text =~ /\A[^>]*?>/
        # html tag
        #puts "OTHER:[#{$&}]"
        store opts[:space_before]
        flush $&
      else
        # never closed tag
        flush
      end
    end

    def scan_asset
      # puts "ASSET(#{object_id}) [#{@text}]"
      if @text =~ /\A<(\w*)([^>]*?)(\/?)>/
        eat $&
        @method = 'rename_asset'
        @markup.tag = @end_tag = $1
        closed = ($3 != '')
        @params = parse_params($2)
        if closed
          leave(:asset)
        elsif @markup.tag == 'script'
          enter(:void)
        else
          enter(:inside_asset)
        end
      else
        # error
        @method = 'void'
        flush
      end
    end

    def scan_inside_asset
      if @text =~ /\A(.*?)<\/#{@end_tag}>/m
        flush $&
        leave(:asset)
      else
        # never ending asset
        flush
      end
    end

    def scan_style
      if @text =~ /\A(.*?)<\/style>/m
        flush $&
        @method = 'rename_asset'
        @markup.tag = 'style'
        leave(:style)
      else
        # error
        @method = 'void'
        flush
      end
    end
  end # ParsingRules
end # Zafu