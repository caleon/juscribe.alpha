require File.dirname(__FILE__) + "/../../../../test/test_helper"

class Mixin < ActiveRecord::Base
  def self.table_name() "articles" end
  
end

class TaggableMixin < Mixin
  acts_as_taggable
  belongs_to :user

end

class TaggableMixinSub1 < TaggableMixin
end

class TaggableMixinSub2 < TaggableMixin
end


class TaggableTest < Test::Unit::TestCase

  def setup
    @user = users(:colin)
    @acc = Hash.new
    (1..4).each { |counter| @acc[counter] = TaggableMixin.create }
  end
  
  def test_find_tagged_with
    acc1 = @acc[1]
    acc2 = @acc[2]
    assert acc1.tag_with('test, test2, test3, test4', :user => @user)
    assert acc2.tag_with('test2, test3, test4, test5', :user => @user)
    assert_equal [acc1], acc1.class.find_tagged_with('test')
    assert_equal [acc1, acc2], acc1.class.find_tagged_with('test2')
    assert_equal [acc1, acc2], acc1.class.find_tagged_with('test2', 'test3')
    assert_equal [acc1, acc2], acc1.class.find_tagged_with('test', 'test2')
    assert_equal [acc2], acc1.class.find_tagged_with('test5')
    assert_equal [acc1, acc2], acc1.class.find_tagged_with('test', 'test5')
    assert_equal [], acc1.class.find_tagged_with('test6', 'test7')
  end
  
  def test_restricted_find_tagged_with
    # TODO: stubbed.
  end
  
  def test_add_tag_and_tag_with
    acc1 = @acc[1]
    assert acc1.tags.empty?
    assert tag = acc1.add_tag('test', :user => @user)
    assert tag.valid? && tag.is_a?(Tag)
    assert tagging = @user.taggings.first
    assert acc1, tagging.taggable
    assert !acc1.reload.tags.empty?
    assert tag2 = acc1.add_tag('test2', :user => @user)
    assert_equal 2, acc1.reload.tags.count
    assert acc1.tag_with('test3, test4, test5', :user => @user)
    assert_equal 5, acc1.reload.tags.count
  end
  
  def test_tag_list
    acc1 = @acc[1]
    assert tag = acc1.add_tag('test', :user => @user)
    assert_equal 'test', acc1.reload.tag_list
    assert tag2 = acc1.add_tag('test2', :user => @user)
    assert_equal 'test, test2', acc1.reload.tag_list
    assert acc1.tag_with('test3, test4, test5', :user => @user)
    assert_equal 'test, test2, test3, test4, test5', acc1.reload.tag_list
  end
  
  def test_find_similar
    # FIXME
    #acc1 = @acc[1]
    #acc2 = @acc[2]
    #acc3 = @acc[3]
    #acc4 = @acc[4]
    #assert acc1.tag_with('test, test2, test3')
    #assert acc2.tag_with('test, test2, test3')
    #assert_equal [acc2], acc1.find_similar
    #assert acc3.tag_with('test4, test5')
    #assert_equal [acc2], acc1.find_similar
    #assert_equal [], acc3.find_similar
    #assert acc4.tag_with('test, test2')
    #assert_equal [acc2, acc4], acc1.find_similar
    #assert_equal [acc2], acc1.find_similar(1)
  end

end
