module Mock
  module Params
    def self.included(base)
      base.before_process :filter_params
    end

    def filter_params
      if klass = @params.delete(:class)
        if klass =~ /#\{/
          res = RubyLess.translate("\"#{klass}\"", self)
          @markup.append_dyn_param(:class, "<%= #{res} %>")
        else
          @markup.append_param(:class, klass)
        end
      end
      true
    end
  end
end