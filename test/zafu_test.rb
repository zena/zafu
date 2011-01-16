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
  safe_method [:raw, String] => String

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

  # ========== YAML TESTS

  yamltest

  def get_template_text(path, base_path)
    folder = base_path.blank? ? [] : base_path.split('/')
    url    = (folder + path[1..-1].split('/'))


    file      = url.shift
    test_name = url.join('_')

    if test = @@test_strings[file][test_name]
      # text, absolute_url, base_path
      [test['src'], (file + test_name), file]
    else
      nil
    end
  end

  def yt_do_test(file, test)
    url  = "/#{file}/#{test}"
    tem  = @@test_strings[file][test]['tem']
    ast  = TestCompiler.new_with_url(url, :helper => self)
    yt_assert tem, ast.to_erb(:node => Zafu::NodeContext.new('@node', Page), :helper => self)
  end

  yt_make
end
