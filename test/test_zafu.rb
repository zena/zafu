require File.dirname(__FILE__) + '/test_helper.rb'

class TestZafu < Test::Unit::TestCase
  include Zafu::TestHelper
  
  def setup
  end
  
  def test_now
    assert_equal "...", now
  end
  
  def test_now_compilation
    assert_equal "<% if var = Time.now -%>", zafu_erb("now", Page)
    assert_equal "8923898", zafu_render("now")
    assert_equal "<% if var = Time.now -%>", Zafu.compile("now", self).to_erb
  end
end
