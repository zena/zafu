module Zafu
  class Template
    def initialize(source, opts = {})
      @options = opts
      @source = "Hello <p style='font-size:64px;'><%= Time.now.strftime('%H:%M:%S') %></p>"
    end

    def src
      src = ::ERB.new("<% __in_erb_template=true %>#{@source}", nil, @options[:erb_trim_mode], '@output_buffer').src

      # Ruby 1.9 prepends an encoding to the source. However this is
      # useless because you can only set an encoding on the first line
      RUBY_VERSION >= '1.9' ? src.sub(/\A#coding:.*\n/, '') : src
    end
  end
end