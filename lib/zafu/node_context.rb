module Zafu
  class NodeContext
    # The name of the variable halding the current object or list ("@node", "var1")
    attr_reader :name

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
      klass.ancestors.include?(type)
    end

    # Return a new node context that corresponds to the current object when rendered alone (in an ajax response or
    # from a direct 'show' in a controller). The returned node context has no parent (up is nil).
    # The convention is to use the class of the current object to build this name.
    def as_main
      NodeContext.new("@#{klass.to_s.underscore}", klass)
    end

    # Generate a unique DOM id for this element based on dom_scopes defined in parent contexts.
    def dom_id
      @dom_id ||= begin
        if @up
          [dom_prefix] + @up.dom_scopes + [make_scope_id]
        else
          [dom_prefix] + [make_scope_id]
        end.compact.uniq.join('_')
      end
    end

    # This holds the current context's unique name if it has it's own or one from the hierarchy. If
    # none is found, it builds one... How ?
    def dom_prefix
      @dom_prefix || (@up ? @up.dom_prefix : nil)
    end

    # Mark the current context as being a looping element (each) whose DOM id needs to be propagated to sub-nodes
    # in order to ensure uniqueness of the dom_id (loops in loops problem).
    def dom_scope!
      @dom_scope = true
    end

    def get(klass)
      if list_context?
        if self.klass.first.ancestors.include?(klass)
          NodeContext.new("#{self.name}.first", self.klass.first)
        elsif @up
          @up.get(klass)
        else
          nil
        end
      elsif self.klass.ancestors.include?(klass)
        return self
      elsif @up
        @up.get(klass)
      else
        nil
      end
    end

    def list_context?
      klass.kind_of?(Array)
    end

    protected
      # List of scopes defined in ancestry (used to generate dom_id).
      def dom_scopes
        (@up ? @up.dom_scopes : []) + (@dom_scope ? [make_scope_id] : [])
      end

    private
      def make_scope_id
        "<%= #{@name}.zip %>"
      end
  end
end