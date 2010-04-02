require 'test_helper'

class String
  def underscore
    gsub(/(^|.)([A-Z])/) {$1 == '' ? $2.downcase : "#{$1}_#{$2.downcase}"}
  end
end

class NodeContextTest < Test::Unit::TestCase
  NodeContext = Zafu::NodeContext

  context 'In a blank context' do
    subject do
      NodeContext.new('@node', Page)
    end

    should 'return the current name' do
      assert_equal '@node', subject.name
    end

    should 'return the current class' do
      assert_equal Page, subject.klass
    end

    should 'return true on will_be with the same class' do
      assert subject.will_be?(Page)
    end

    should 'return false on will_be with a sub class' do
      assert !subject.will_be?(SubPage)
    end

    should 'return false on will_be with a different class' do
      assert !subject.will_be?(String)
    end

    should 'return self on a get for the same class' do
      assert_equal subject.object_id, subject.get(Page).object_id
    end

    should 'return nil on a get for another class' do
      assert_nil subject.get(Comment)
    end
    
    context 'calling as_main' do
      should 'build the name from the class' do
        assert_equal '@page', subject.as_main.name
      end
      
      should 'return same class' do
        assert_equal subject.klass, subject.as_main.klass
      end
    end

    context 'with a sub-class' do
      subject do
        NodeContext.new('@node', SubPage)
      end

      should 'return true on will_be with the same class' do
        assert subject.will_be?(SubPage)
      end

      should 'return true on will_be with a super class' do
        assert subject.will_be?(Page)
      end

      should 'return false on will_be with a different class' do
        assert !subject.will_be?(String)
      end
      
      context 'calling as_main' do
        should 'build the name from the class' do
          assert_equal '@sub_page', subject.as_main.name
        end

        should 'return same class' do
          assert_equal subject.klass, subject.as_main.klass
        end
        
        should 'return an ancestor when using after_class argument' do
          subject = NodeContext.new('@node', SubSubPage)
          assert_equal SubPage, subject.as_main(Page).klass
        end
      end
    end # with a sub-class
  end

  context 'In a sub-context' do
    setup do
      @parent  = NodeContext.new('@node', Page)
    end

    subject do
      @parent.move_to('comment1', Comment)
    end

    should 'return the current name' do
      assert_equal 'comment1', subject.name
    end

    should 'return the current class' do
      assert_equal Comment, subject.klass
    end

    should 'return self on a get for the same class' do
      assert_equal subject.object_id, subject.get(Comment).object_id
    end

    should 'return the parent on a get for the class of the parent' do
      assert_equal @parent.object_id, subject.get(Page).object_id
    end
  end

  context 'In a deeply nested context' do
    setup do
      @grandgrandma = NodeContext.new('@comment', Comment)
      @grandma = @grandgrandma.move_to('page', Page)
      @mother  = @grandma.move_to('comment1', Comment)
    end

    subject do
      @mother.move_to('var1', String)
    end

    should 'return the current name' do
      assert_equal 'var1', subject.name
    end

    should 'return the current class' do
      assert_equal String, subject.klass
    end

    should 'return the first ancestor matching class on get' do
      assert_equal @mother.object_id, subject.get(Comment).object_id
    end

    should 'return nil if no ancestor matches class on get' do
      assert_nil subject.get(Fixnum)
    end
  end

  context 'In a sub-classes context' do
    subject do
      NodeContext.new('super', SubPage)
    end

    should 'find the current context required class is an ancestor' do
      assert_equal subject.object_id, subject.get(Page).object_id
    end
  end

  context 'In a list context' do
    subject do
      NodeContext.new('list', [Page])
    end

    should 'find the context and resolve with first' do
      assert context = subject.get(Page)
      assert_equal 'list.first', context.name
      assert_equal Page, context.klass
    end
  end

  context 'Generating a dom id' do
    context 'in a blank context' do
      subject do
        NodeContext.new('@foo', Page)
      end

      should 'return the node name in DOM id' do
        assert_equal '<%= @foo.zip %>', subject.dom_id
      end
    end

    context 'in a hierarchy of contexts' do
      setup do
        @a       = NodeContext.new('@node', Page)
        @b       = NodeContext.new('var1', [Page], @a)
        @c       = NodeContext.new('var2', Page, @b)
      end

      subject do
        NodeContext.new('var3', Page, @c)
      end

      context 'with parents as dom_scopes' do
        setup do
          @b.dom_scope!
          @c.dom_scope!
        end

        should 'use dom_scopes' do
          assert_equal '<%= var1.zip %>_<%= var2.zip %>_<%= var3.zip %>', subject.dom_id
        end
      end

      context 'with ancestors and self as dom_scopes' do
        setup do
          @a.dom_scope!
          subject.dom_scope!
        end

        should 'not use self twice' do
          assert_equal '<%= @node.zip %>_<%= var3.zip %>', subject.dom_id
        end
      end

      context 'with a parent defining a dom_prefix' do
        setup do
          @b.dom_prefix = 'cart'
        end

        should 'use dom_prefix' do
          assert_equal 'cart_<%= var3.zip %>', subject.dom_id
        end
      end

    end
  end
end






