require 'rubyless'

module Zafu
  module Process
    module RubyLessProcessing
      include RubyLess

      def self.included(base)
        base.process_unknown :rubyless_eval

        base.class_eval do
          def do_method(sym)
            super
          rescue RubyLess::Error => err
            parser_error(err.message)
          end
        end
      end

      # Actual method resolution. The lookup first starts in the current helper. If nothing is found there, it
      # searches inside a 'helpers' module and finally looks into the current node_context.
      # If nothing is found at this stage, we prepend the method with the current node and start over again.
      def safe_method_type(signature, receiver = nil)
        #puts [node.name, node.klass, signature].inspect
        super || get_method_type(signature, false)
      end

      # Resolve unknown methods by using RubyLess in the current compilation context (the
      # translate method in RubyLess will call 'safe_method_type' in this module).
      def rubyless_eval(params = @params)
        if @method =~ /^[A-Z]\w+$/
          return rubyless_class_scope(@method)
        end

        if code = @method[/^\#\{(.+)\}$/, 1]
          params[:eval] = $1
          r_show
        else
          rubyless_render(@method, params)
        end
      rescue RubyLess::NoMethodError => err
        parser_continue("#{err.error_message} <span class='type'>#{err.method_with_arguments}</span> for #{err.receiver_with_class}")
      rescue RubyLess::Error => err
        parser_continue(err.message)
      end

      # Print documentation on the current node type.
      def r_m
        if @params[:helper] == 'true'
          klass = helper.class
        else
          klass = node.klass
        end

        out "<div class='rubyless-m'><h3>Documentation for <b>#{klass}</b></h3>"
        out "<ul>"
        RubyLess::SafeClass.safe_methods_for(klass).each do |signature, opts|
          opts = opts.dup
          opts.delete(:method)
          if opts.keys == [:class]
            opts = opts[:class]
          end
          out "<li>#{signature.inspect} => #{opts.inspect}</li>"
        end
        out "</ul></div>"
      end

      # TEMPORARY METHOD DURING HACKING...
      def r_erb
        "<pre><%= @erb.gsub('<','&lt;').gsub('>','&gt;') %></pre>"
      end

      def rubyless_render(method, params)
        # We need to set this here because we cannot pass options to RubyLess or get them back
        # when we evaluate the method to see if we can use blocks as arguments.
        @rendering_block_owner = true
        code = method_with_arguments(method, params)
        rubyless_expand RubyLess.translate(self, code)
      ensure
        @rendering_block_owner = false
      end

      def set_markup_attr(markup, key, value)
        value = value.kind_of?(RubyLess::TypedString) ? value : RubyLess.translate_string(self, value)
        if value.literal
          markup.set_param(key, value.literal)
        else
          markup.set_dyn_param(key, "<%= #{value} %>")
        end
      end

      def append_markup_attr(markup, key, value)
        value = RubyLess.translate_string(self, value)
        if value.literal
          markup.append_param(key, value.literal)
        else
          markup.append_dyn_param(key, "<%= #{value} %>")
        end
      end

      def get_attribute_or_eval(use_string_block = true)
        if attribute = @params[:attr] || @params[:date]
          code = "this.#{attribute}"
        elsif code = @params[:eval] || @params[:test]
        elsif text = @params[:text]
          code = "%Q{#{text}}"
        elsif use_string_block && @blocks.size == 1 && @blocks.first.kind_of?(String)
          return RubyLess::TypedString.new(@blocks.first.inspect, :class => String, :literal => @blocks.first)
        else
          return parser_continue("Missing attribute/eval parameter")
        end

        RubyLess.translate(self, code)
      rescue RubyLess::Error => err
        return parser_continue(err.message, code)
      end

      private
        # Extract arguments from params
        def extract_from_params(*keys)
          res = []

          keys.each do |key|
            next unless value = @params[key.to_sym]
            res << ":#{key} => #{RubyLess.translate_string(self, value)}"
          end

          res.empty? ? nil : res
        end

        # Method resolution. The first matching method is returned. Order of evaluation is
        # 1. find node_context (@page, @image, self)
        # 2. set var (set_xxx = '...')
        # 3. template helper methods
        # 4. contextual node methods (var1.xxx)
        # 5. contextual first node of list method ([...].first.xxx)
        # 6. append block as argument (restart 1-5 with xxx(block_string))
        def get_method_type(signature, added_options = false)
          node = self.node
          raise "#{node.klass.class}" unless node.klass.kind_of?(Array) || node.klass.kind_of?(Class)

          if type = node_context_from_signature(signature)
            # Resolve self, @page, @node
            type
          elsif type = get_var_from_signature(signature)
            # Resolved stored set_xxx='something' in context.
            type
          elsif type = safe_method_from(helper, signature)
            # Resolve template helper methods
            type
          elsif helper.respond_to?(:helpers) && type = safe_method_from(helper.helpers, signature)
            # Resolve by looking at the included helpers
            type
          elsif node && !node.list_context? && type = safe_method_from(node.klass, signature, node)
            # not a list_contex
            # Resolve node context methods: xxx.foo, xxx.bar
            type.merge(:method => "#{node.name}.#{type[:method]}")
          elsif node && node.list_context? && type = safe_method_from(node.klass.first, signature, node)
            type.merge(:method => "#{node.name}.first.#{type[:method]}")
          elsif @rendering_block_owner && @blocks.first.kind_of?(String) && !added_options
            # Insert the block content into the method: <r:trans>blah</r:trans> becomes trans("blah")
            signature_with_block = signature.dup
            signature_with_block << String
            if type = get_method_type(signature_with_block, true)
              type.merge(:prepend_args => RubyLess::TypedString.new(@blocks.first.inspect, :class => String, :literal => @blocks.first))
            else
              nil
            end
          elsif node && !added_options
            # Try prepending current node before arguments: link("foo") becomes link(var1, "foo")
            signature_with_node = signature.dup
            signature_with_node.insert(1, node.klass)
            if type = get_method_type(signature_with_node, added_options = true)
              type.merge(:prepend_args => RubyLess::TypedString.new(node.name, :class => node.klass))
            else
              nil
            end
          else
            nil
          end
        end

        def method_with_arguments(method, params)
          hash_arguments = []
          arguments = []
          params.keys.sort {|a,b| a.to_s <=> b.to_s}.each do |k|
            if k =~ /\A_/
              arguments << "%Q{#{params[k]}}"
            else
              hash_arguments << ":#{k} => %Q{#{params[k]}}"
            end
          end

          if hash_arguments != []
            arguments << hash_arguments.join(', ')
          end

          if arguments != []
            if method =~ /^(.*)\((.*)\)$/
              if $2 == ''
                "#{$1}(#{arguments.join(', ')})"
              else
                "#{$1}(#{$2}, #{arguments.join(', ')})"
              end
            else
              "#{method}(#{arguments.join(', ')})"
            end
          else
            method
          end
        end

        def rubyless_expand(res)
          if res.klass == String && !@blocks.detect {|b| !b.kind_of?(String)}
            if lit = res.literal
              out lit
            else
              out "<%= #{res} %>"
            end
          elsif @blocks.empty?
            out "<%= #{res} %>"
          elsif res.could_be_nil?
            expand_with_finder(:method => res, :class => res.klass, :nil => true)
          else
            expand_with_finder(:method => res, :class => res.klass)
          end
        end

        def rubyless_class_scope(class_name)
          # capital letter ==> class conditional
          klass = Module.const_get(class_name)
          if klass.ancestors.include?(node.klass)
            expand_if("#{node}.kind_of?(#{klass})")
          else
            # render nothing: incompatible classes
            ''
          end
        rescue
          parser_error("Invalid class name '#{class_name}'")
        end

        # Find a class or behavior based on a name. The returned class should implement
        # 'safe_method_type'.
        def get_class(class_name)
          Module.const_get(class_name)
        rescue
          nil
        end

        # This is used to resolve 'this' (current NodeContext), '@node' as NodeContext with class Node,
        # '@page' as first NodeContext of type Page, etc.
        def node_context_from_signature(signature)
          return nil unless signature.size == 1
          ivar = signature.first
          if ivar == 'this'
            if node.list_context?
              raise RubyLess::Error.new("Cannot use 'this' in list_context.")
            else
              node.opts.merge(:class => node.klass, :method => node.name)
            end
          elsif ivar[0..0] == '@' && klass = get_class(ivar[1..-1].capitalize)
            if node = self.node(klass)
              node.opts.merge(:class => node.klass, :method => node.name)
            else
              nil
            end
          else
            nil
          end
        end

        # Find stored variables back. Stored elements are set with set_xxx='something to eval'.
        def get_var_from_signature(signature)
          return nil unless signature.size == 1
          if var = get_context_var('set_var', signature.first)
            {:method => var, :class => var.klass, :nil => var.could_be_nil?}
          else
            nil
          end
        end

        def safe_method_from(solver, signature, receiver = nil)

          if solver.respond_to?(:safe_method_type)
            solver.safe_method_type(signature, receiver)
          else
            RubyLess::SafeClass.safe_method_type_for(solver, signature)
          end
        end

    end # RubyLessProcessing
  end # Process
end # Zafu