module Zafu
  class NodeContext
    # The name of the variable halding the current object or list ("@node", "var1")
    attr_reader :name

    # The previous NodeContext
    attr_reader :up

    # The type of object contained in the current context (Node, Page, Image)
    attr_reader :klass

    # The current DOM prefix to use when building DOM ids. This is set by the parser when
    # it has a name or dom id defined ('main', 'related', 'list', etc).
    attr_writer :dom_prefix

    def initialize(name, klass, up = nil)
      @name, @klass, @up = name, klass, up
    end

    def move_to(name, klass)
      NodeContext.new(name, klass, self)
    end

    # Since the idiom to write the node context name is the main purpose of this class, it
    # deserves this shortcut.
    def to_s
      name
    end

    # Return true if the NodeContext represents an element of the given type. We use 'will_be' because
    # it is equivalent to 'is_a', but for future objects (during rendering).
    def will_be?(type)
      klass.kind_of?(Array) ? klass.first.ancestors.include?(type) : klass.ancestors.include?(type)
    end

    # Return a new node context that corresponds to the current object when rendered alone (in an ajax response or
    # from a direct 'show' in a controller). The returned node context has no parent (up is nil).
    # The convention is to use the class of the current object to build this name.
    # You can also use an 'after_class' parameter to move up in the current object's class hierarchy to get
    # ivar name (see #master_class).
    def as_main(after_class = nil)
      klass = after_class ? master_class(after_class) : Array(self.klass).first
      NodeContext.new("@#{klass.to_s.underscore}", Array(self.klass).first)
    end

    # Find the class just afer 'after_class' in the class hierarchy.
    # For example if we have Dog < Mamal < Animal < Creature,
    # master_class(Creature) would return Animal
    def master_class(after_class)
      klass = self.klass
      klass = klass.first if klass.kind_of?(Array)
      begin
        up = klass.superclass
        return klass if up == after_class
      end while klass = up
      return self.klass
    end

    # Generate a unique DOM id for this element based on dom_scopes defined in parent contexts.
    def dom_id(opts = {})
      options = {:list => true, :erb => true}.merge(opts)

      if options[:erb]
        dom = dom_id(options.merge(:erb => false))
        if dom =~ /^#\{([^\{]+)\}$/
          "<%= #{$1} %>"
        elsif dom =~ /#\{/
          "<%= %Q{#{dom}} %>"
        else
          dom
        end
      else
        if @up
          [dom_prefix] + @up.dom_scopes + (options[:list] ? [make_scope_id] : [])
        else
          [dom_prefix] + (options[:list] ? [make_scope_id] : [])
        end.compact.uniq.join('_')
      end
    end

    # This holds the current context's unique name if it has it's own or one from the hierarchy. If
    # none is found, it builds one.
    def dom_prefix
      @dom_prefix || (@up ? @up.dom_prefix : nil)
    end

    # Mark the current context as being a looping element (each) whose DOM id needs to be propagated to sub-nodes
    # in order to ensure uniqueness of the dom_id (loops in loops problem).
    def propagate_dom_scope!
      @dom_scope = true
    end

    def get(klass)
      if list_context?
        if self.klass.first <= klass
          NodeContext.new("#{self.name}.first", self.klass.first)
        elsif @up
          @up.get(klass)
        else
          nil
        end
      elsif self.klass <= klass
        return self
      elsif @up
        @up.get(klass)
      else
        nil
      end
    end

    def up(klass = nil)
      klass ? @up.get(klass) : @up
    end

    # Return true if the current klass is an Array.
    def list_context?
      klass.kind_of?(Array)
    end

    # Return the name of the current class with underscores like 'sub_page'.
    def underscore
      class_name.to_s.underscore
    end

    # Return the class name or the superclass name if the current class is an anonymous class.
    # FIXME: just use klass.to_s (so that we can do clever things with 'to_s')
    def class_name
      if list_context?
        klass = @klass.first
        "[#{(klass.name.blank? ? klass.superclass : klass).name}]"
      else
        (@klass.name.blank? ? @klass.superclass : @klass).name
      end
    end

    # Return the name to use for input fields
    def form_name
      @form_name ||= master_class(ActiveRecord::Base).name.underscore
    end

    protected
      # List of scopes defined in ancestry (used to generate dom_id).
      def dom_scopes
        (@up ? @up.dom_scopes : []) + (@dom_scope ? [make_scope_id] : [])
      end

    private
      def make_scope_id
        "\#{#{@name}.zip}"
      end
  end
end