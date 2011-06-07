module Mock
  module Params
    def self.included(base)
      base.before_process :filter_post_string
    end

    def filter_post_string
      if str = @params.delete(:post_string)
        out_post str
      end
    end


    def r_inspect
      out "#{@params.inspect}"
    end
  end
end