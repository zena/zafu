class Page
  include RubyLess
  safe_context :root => Page
end

class SubPage < Page
end

class Comment
end
