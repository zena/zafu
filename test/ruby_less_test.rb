require 'test_helper'

class ZafuRubyLessTest < Test::Unit::TestCase
  include RubyLess
  def self.process_unknown(callback); end;
  include Zafu::Security
  include Zafu::Process::RubyLessProcessing
  def helper; self.class; end
  safe_method :one => {:class => String, :method => "main_one"}


  context 'With a Markup' do
    setup do
      @markup = Zafu::Markup.new('p')
    end

    context 'parsing an attribute without dynamic strings' do
      should 'not alter string' do
        set_markup_attr(@markup, :name, 'this is a string')
        assert_equal '<p name=\'this is a string\'>foo</p>', @markup.wrap('foo')
      end
    end

    context 'parsing an attribute with dynamic content' do
      should 'use RubyLess to translate content' do
        set_markup_attr(@markup, :name, 'this #{one}')
        assert_equal '<p name=\'<%= "this #{main_one}" %>\'>foo</p>', @markup.wrap('foo')
      end

      context 'with ruby errors' do
        should 'raise a RubyLess::SyntaxError' do
          assert_raises(RubyLess::SyntaxError) do
            set_markup_attr(@markup, :name, 'this #{one}}')
          end
        end

        should 'produce an error message with the original attribute' do
          begin
            set_markup_attr(@markup, :name, 'this #{one}}')
          rescue RubyLess::Error => err
            assert_match %r{parse error on value "\}" \(tRCURLY\)}, err.message
          end
        end
      end
    end
  end
  
  context 'With an invalid string' do
    subject do
      'contact where id #{params[:foo]} in site'
    end

    should 'not alter string on error' do
      str = subject.dup
      begin
        x = RubyLess.translate(self, str)
      rescue RubyLess::Error => err
        assert_equal subject, str
      end
    end
  end # With an invalid string
  

end
