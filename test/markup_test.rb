require 'test_helper'

class String
  def blank?
    self == ''
  end
end

class NodeContextTest < Test::Unit::TestCase
  Markup = Zafu::Markup

  context 'Parsing parameters' do
    should 'retrieve values escaped with single quotes' do
      h = {:class => 'worker', :style => 'tired'}
      assert_equal h, Markup.parse_params("class='worker' style='tired'")
    end

    should 'retrieve values escaped with double quotes' do
      h = {:class => 'worker', :style => 'tired'}
      assert_equal h, Markup.parse_params('class="worker" style="tired"')
    end

    should 'retrieve values escaped with mixed quotes' do
      h = {:class => 'worker', :style => 'tired'}
      assert_equal h, Markup.parse_params('class=\'worker\' style="tired"')
    end

    should 'properly handle escaped single quotes' do
      h = {:class => "that's nice", :style => 'tired'}
      assert_equal h, Markup.parse_params("class='that\\\'s nice' style='tired'")
    end

    should 'properly handle escaped double quotes' do
      h = {:class => '30"', :style => 'tired'}
      assert_equal h, Markup.parse_params('class="30\\"" style="tired"')
    end
  end

  context 'Setting parameters' do
    setup do
      @markup = Markup.new('p')
    end

    should 'parse params if the parameters are provided as a string' do
      @markup.params = "class='shiny' id='slogan'"
      h = {:class => 'shiny', :id => 'slogan'}
      assert_equal h, @markup.params
    end

    should 'set params if the parameters are provided as a hash' do
      @markup.params = {:class => 'shiny', :style => 'good'}
      h = {:class => 'shiny', :style => 'good'}
      assert_equal h, @markup.params
    end
  end

  context 'Stealing html params' do
    setup do
      @markup = Markup.new('p')
    end

    should 'remove common html params' do
      base = {:class => 'blue', :name => 'sprout', :id => 'front_cover', :style => 'padding:5px;', :attr => 'title'}
      @markup.steal_html_params_from(base)
      new_base = {:name => 'sprout', :attr => 'title'}
      markup_params = {:class => 'blue', :id => 'front_cover', :style => 'padding:5px;'}
      assert_equal new_base, base
      assert_equal markup_params, @markup.params
    end
  end

  context 'Defining the dom id' do
    setup do
      @markup = Markup.new('p')
      @markup.params[:id] = 'foobar'
      @markup.dyn_params[:id] = 'foobar'
      @markup.set_id('<%= @node.zip %>')
    end

    should 'remove any predifined id' do
      assert_nil @markup.params[:id]
    end

    should 'write id in the dynamic params' do
      assert_equal '<%= @node.zip %>', @markup.dyn_params[:id]
    end
  end

  context 'Setting a dynamic param' do
    setup do
      @markup = Markup.new('p')
      @markup.params[:foo] = 'one'
      @markup.set_dyn_params(:foo => '<%= @node.two %>')
    end

    should 'clear a static param with same key' do
      assert_nil @markup.params[:foo]
      assert_equal '<%= @node.two %>', @markup.dyn_params[:foo]
    end
  end

  context 'Setting a static param' do
    setup do
      @markup = Markup.new('p')
      @markup.dyn_params[:foo] = 'one'
      @markup.set_params(:foo => '<%= @node.two %>')
    end

    should 'clear a dynamic param with same key' do
      assert_nil @markup.dyn_params[:foo]
      assert_equal '<%= @node.two %>', @markup.params[:foo]
    end
  end

  context 'Wrapping some text' do
    setup do
      @text = 'Alice: It would be so nice if something made sense for a change.'
      @markup = Markup.new('p')
      @markup.params = {:class => 'quote', :style => 'padding:3px; border:1px solid red;'}
    end

    should 'add the markup tag around the text' do
      assert_equal "<p class='quote' style='padding:3px; border:1px solid red;'>#{@text}</p>", @markup.wrap(@text)
    end

    should 'not wrap twice if called twice' do
      assert_equal "<p class='quote' style='padding:3px; border:1px solid red;'>#{@text}</p>", @markup.wrap(@markup.wrap(@text))
    end
  end
end




