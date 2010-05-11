module Foo
end

unless defined?(ActiveRecord)
  module ActiveRecord
    class Base
    end
  end
end

class Page < ActiveRecord::Base
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
