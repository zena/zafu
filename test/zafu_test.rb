require 'test_helper'

class String
  def blank?
    self == ''
  end
end

class ZafuTest < Test::Unit::TestCase
  include RubyLess
  include Zafu::TestHelper
  safe_method :one => {:class => String, :method => "main_one"}
  
  class Dummy
    include RubyLess
    safe_method :hello => String
    safe_method :one => {:class => String, :method => "dummy_one"}
  end
  safe_method :dum  => Dummy
  safe_method :dum2 => {:class => Dummy, :nil => true}

  context 'Compilation in a model' do
    setup do
      @node_context = Zafu::NodeContext.new('@test', Dummy)
    end

    should 'start method lookup in the template' do
      assert_equal '<%= main_one %>', zafu_erb('<r:one/>')
    end

    should 'use the model to resolve methods' do
      assert_equal '<%= @test.hello %>', zafu_erb('<r:hello/>')
    end

    should 'change node context by following safe_method types' do
      assert_equal '<% var1 = dum -%><%= var1.hello %>', zafu_erb("<r:dum do='hello'/>")
    end

    context 'that can be nil' do
      should 'wrap context in if' do
        assert_equal '<% if var1 = dum2 -%><%= var1.hello %><% end -%>', zafu_erb("<r:dum2 do='hello'/>")
      end
    end
  end
  
  context 'a custom compiler' do
    setup do
      @compiler = TestCompiler
    end
    
    should 'execute before_process callbacks' do
      res = zafu_erb("<p class='simple' do='one' class='foo\#{dum.one}'/>", self, @compiler)
      assert_match %r{class='simple <%= "foo\#\{dum.dummy_one\}"}, res
    end
  end

end
