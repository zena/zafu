require File.dirname(__FILE__) + '/test_helper.rb'

class NodeContextTest < Test::Unit::TestCase
  class Page;end
  class SuperPage < Page; end
  class Comment;end
  NodeContext = Zafu::NodeContext

  context 'In a blank context' do
    setup do
      @context = NodeContext.new('@node', Page)
    end

    should 'return the current name' do
      assert_equal '@node', @context.name
    end

    should 'return the current class' do
      assert_equal Page, @context.klass
    end

    should 'return self on a get for the same class' do
      assert_equal @context.object_id, @context.get(Page).object_id
    end

    should 'return nil on a get for another class' do
      assert_nil @context.get(Comment)
    end
  end

  context 'In a sub-context' do
    setup do
      @parent  = NodeContext.new('@node', Page)
      @context = @parent.move_to('comment1', Comment)
    end

    should 'return the current name' do
      assert_equal 'comment1', @context.name
    end

    should 'return the current class' do
      assert_equal Comment, @context.klass
    end

    should 'return self on a get for the same class' do
      assert_equal @context.object_id, @context.get(Comment).object_id
    end

    should 'return the parent on a get for the class of the parent' do
      assert_equal @parent.object_id, @context.get(Page).object_id
    end
  end

  context 'In a deeply nested context' do
    setup do
      @grandgrandma = NodeContext.new('@comment', Comment)
      @grandma = @grandgrandma.move_to('page', Page)
      @mother  = @grandma.move_to('comment1', Comment)
      @context = @mother.move_to('var1', String)
    end

    should 'return the current name' do
      assert_equal 'var1', @context.name
    end

    should 'return the current class' do
      assert_equal String, @context.klass
    end

    should 'return the first ancestor matching class on get' do
      assert_equal @mother.object_id, @context.get(Comment).object_id
    end

    should 'return nil if no ancestor matches class on get' do
      assert_nil @context.get(Fixnum)
    end
  end

  context 'In a sub-classes context' do
    setup do
      @context = NodeContext.new('super', SuperPage)
    end

    should 'find the current context required class is an ancestor' do
      assert_equal @context.object_id, @context.get(Page).object_id
    end
  end

  context 'In a list context' do
    setup do
      @context = NodeContext.new('list', [Page])
    end

    should 'find the context and resolve with first' do
      assert context = @context.get(Page)
      assert_equal 'list.first', context.name
      assert_equal Page, context.klass
    end
  end
end