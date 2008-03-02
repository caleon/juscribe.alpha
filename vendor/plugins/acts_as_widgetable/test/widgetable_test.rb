require File.dirname(__FILE__) + "/../../../../test/test_helper"

class Mixin < ActiveRecord::Base
end

class WidgetableMixin < Mixin
  acts_as_widgetable
  belongs_to :user

  def self.table_name() "articles" end
end

class WidgetableMixinSub1 < WidgetableMixin
end

class WidgetableMixinSub2 < WidgetableMixin
end


class WidgetableTest < Test::Unit::TestCase

  def setup
    @user = users(:colin)
    @acc = Hash.new
    (1..4).each { |counter| @acc[counter] = WidgetableMixin.create }
  end
  
  def test_clip
    acc1 = @acc[1]
    assert_raise(ArgumentError) { acc1.clip! }
    assert clip = acc1.clip!(:user => @user)
    assert clip.is_a?(Widget)
    assert_equal @user, clip.user
    assert_equal [clip], acc1.clips
    assert_equal [clip], @user.widgets
    assert !clip.placed?
    assert_raise(ActiveRecord::RecordInvalid) { acc1.clip!(:user => @user) }
    
    acc2 = @acc[2]
    assert clip2 = acc2.clip!(:user => @user, :position => 55)
    assert_equal 55, clip2.position
    
    assert clip.place(4)
    assert_equal 4, clip.position
    assert clip2.place(4)
    assert_equal 4, clip2.position
    assert !clip.reload.placed?
  end
  
  def test_unclip
    acc1 = @acc[1]
    assert clip = acc1.clip!(:user => @user)
    assert acc1.clip_for?(@user)
    assert clip = acc1.clip_for(@user)
    assert !clip.placed?
    assert_raise(ArgumentError) { acc1.unclip! }
    assert acc1.unclip!(:user => @user)
    assert !acc1.clip_for?(@user)
    assert_nil acc1.clip_for(@user)
  end


end
