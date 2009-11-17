module Zafu
  class NodeContext
    attr_reader :name, :klass
    def initialize(name, klass, up = nil)
      @name, @klass, @up = name, klass, up
    end

    def move_to(name, klass)
      NodeContext.new(name, klass, self)
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
  end
end