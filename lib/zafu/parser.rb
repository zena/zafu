module Zafu
  class Parser
    def initialize(source, opts = {})
    end

    def render(view, local_assigns)
      "<p style='font-size:64px;'>#{Time.now.strftime('%H:%M:%S')}</p>\n
      <pre>#{view.inspect.gsub('>', '&gt;').gsub('<', '&lt;')}</pre>"
    end
  end
end