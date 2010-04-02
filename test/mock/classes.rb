module Foo
end

class Page
  include RubyLess
  safe_context :root => Page
end

class SubPage < Page
  include Foo
end

class SubSubPage < SubPage
end

class Comment
end
