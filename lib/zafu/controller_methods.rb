module Zafu
  module ControllerMethods
    def self.included(base)
      base.helper_method :zafu_context, :get_template_text
      base.helper Zafu::Helper
    end

    def zafu_context
      @zafu_context ||= {}
    end

    def get_template_text(opts = {})
      nil
    end
  end
end