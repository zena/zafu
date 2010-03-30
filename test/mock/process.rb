module Mock
  module Process
    def r_link
      out "<%= make_link(#{node}) %>"
    end
  end
end