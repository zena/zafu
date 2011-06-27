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
      out "#{@params.inspect} xxxx"
    end

    # Test passing information to siblings
    def r_pass
      pass(@params)
      true
    end

    def r_view_passed
      key = @params[:key]
      out @context[@params[:key].to_sym].to_s
    end
  end
end