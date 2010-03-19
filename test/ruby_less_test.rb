require 'test_helper'

class ZafuRubyLessTest < Test::Unit::TestCase
  include RubyLess::SafeClass
  include Zafu::Process::RubyLess
  def helper; self.class; end
  safe_method :one => {:class => String, :method => "main_one"}

  context 'Parsing an attribute without dynamic strings' do
    should 'not alter string' do
      assert_equal '"this is a string"', rubyless_attr('this is a string')
    end
  end

  context 'Parsing an attribute with dynamic content' do
    should 'use RubyLess to translate content' do
      assert_equal '"this #{main_one}"', rubyless_attr('this #{one}')
    end

    context 'with ruby errors' do
      should 'raise a RubyLess::Error' do
        assert_raises(::RubyLess::Error) do
          rubyless_attr('this #{one}}')
        end
      end

      should 'produce an error message with the original attribute' do
        begin
          rubyless_attr('this #{one}}')
        rescue ::RubyLess::Error => err
          assert_equal 'Error parsing string "this #{one}}": parse error on value "}" (tRCURLY)', err.message
        end
      end
    end
  end

end
