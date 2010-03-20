module Zafu
  # A Markup object is used to hold information on the tag used (<li>), it's parameters (.. class='xxx') and
  # indentation.
  class Markup
    EMPTY_TAGS   = %w{meta input}
    STEAL_PARAMS = [:class, :id, :style]

    # Tag used ("li" for example). The tag can be nil (no tag).
    attr_accessor :tag
    # Tag parameters (.. class='xxx' id='yyy')
    attr_accessor :params
    # Dynamic tag parameters that should not be escaped. For example: (.. class='<%= @node.klass %>')
    attr_accessor :dyn_params
    # Ensure wrap is not called more then once unless this attribute has been reset in between
    attr_accessor :done
    # Space to insert before tag
    attr_accessor :space_before
    # Space to insert after tag
    attr_accessor :space_after

    class << self

      # Parse parameters into a hash. This parsing supports multiple values for one key by creating additional keys:
      # <tag do='hello' or='goodbye' or='gotohell'> creates the hash {:do=>'hello', :or=>'goodbye', :or1=>'gotohell'}
      def parse_params(text)
        return {} unless text
        return text if text.kind_of?(Hash)
        params = {}
        rest = text.strip
        while (rest != '')
          if rest =~ /(.+?)=/
            key = $1.strip.to_sym
            rest = rest[$&.length..-1].strip
            if rest =~ /('|")(|[^\1]*?[^\\])\1/
              rest = rest[$&.length..-1].strip
              key_counter = 1
              while params[key]
                key = "#{key}#{key_counter}".to_sym
                key_counter += 1
              end

              if $1 == "'"
                params[key] = $2.gsub("\\'", "'")
              else
                params[key] = $2.gsub('\\"', '"')
              end
            else
              # error, bad format, return found params.
              break
            end
          else
            # error, bad format
            break
          end
        end
        params
      end
    end

    def initialize(tag)
      @done       = false
      @tag        = tag
      @params     = {}
      @dyn_params = {}
    end

    # Set params either using a string (like "alt='time passes' class='zen'")
    def params=(p)
      if p.kind_of?(Hash)
        @params = p
      else
        @params = Markup.parse_params(p)
      end
    end

    # Steal html parameters from an existing hash (the stolen parameters are removed
    # from the argument)
    def steal_html_params_from(p)
      @params ||= {}
      STEAL_PARAMS.each do |k|
        next unless p[k]
        @params[k] = p.delete(k)
      end
    end

    # Compile dynamic parameters as ERB. A parameter is considered dynamic if it
    # contains the string eval "#{...}"
    def compile_params(helper)
      @params.each do |key, value|
        if value =~ /^(.*)\#\{(.*)\}(.*)$/
          @params.delete(key)
          if $1 == '' && $3 == ''
            append_dyn_param(key, "<%= #{RubyLess.translate($2, helper)} %>")
          else
            append_dyn_param(key, "<%= #{RubyLess.translate_string(value, helper)} %>")
          end
        end
      end
    end

    # Set dynamic html parameters.
    def set_dyn_params(hash)
      hash.keys.each do |k|
        @params.delete(k)
      end
      @dyn_params.merge!(hash)
    end

    # Set static html parameters.
    def set_params(hash)
      hash.keys.each do |k|
        @dyn_params.delete(k)
      end
      @params.merge!(hash)
    end

    def append_param(key, value)
      if prev_value = @dyn_params[key]
        @dyn_params[key] = "#{prev_value} #{value}"
      elsif prev_value = @params[key]
        @params[key] = "#{prev_value} #{value}"
      else
        @params[key] = value
      end
    end

    def append_dyn_param(key, value)
      if prev_value = @params.delete(key)
        @dyn_params[key] = "#{prev_value} #{value}"
      elsif prev_value = @dyn_params[key]
        @dyn_params[key] = "#{prev_value} #{value}"
      else
        @dyn_params[key] = value
      end
    end

    # Define the DOM id from a node context
    def set_id(erb_id)
      params[:id] = nil
      dyn_params[:id] = erb_id
    end

    # Wrap the given text with our tag. If 'append' is not empty, append the text
    # after the tag parameters: <li class='foo'[APPEND HERE]>text</li>.
    def wrap(text, *append)
      return text if @done
      append ||= []
      if @tag
        if text.blank? && EMPTY_TAGS.include?(@tag)
          res = "<#{@tag}#{params_to_html}#{append.join('')}/>"
        else
          res = "<#{@tag}#{params_to_html}#{append.join('')}>#{text}</#{@tag}>"
        end
      else
        res = text
      end
      @done = true

      (@space_before || '') + res + (@space_after || '')
    end

    private
      def params_to_html
        para = []
        keys = []

        @dyn_params.each do |k,v|
          keys << k
          para << " #{k}='#{v}'"
        end

        @params.each do |k,v|
          next if keys.include?(k)

          if !v.to_s.include?("'")
            para << " #{k}='#{v}'"
          else
            para << " #{k}=\"#{v.to_s.gsub('"','\"')}\"" # TODO: do this work in all cases ?
          end
        end

        # we sort so that the output is always the same (needed for testing)
        para.sort.join('')
      end
  end
end