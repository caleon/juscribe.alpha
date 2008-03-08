require File.dirname(__FILE__) + '/../test_helper'

class Mixin < ActiveRecord::Base
  set_table_name 'articles'
end

class WidgetableMixin < Mixin
  acts_as_widgetable
  belongs_to :user

  def title; self[:title] || "untitled"; end
end

class WidgetableMixinSub1 < WidgetableMixin
end

class WidgetableMixinSub2 < WidgetableMixin
end


class WidgetableTest < ActiveSupport::TestCase

  def setup
    @user = users(:colin)
    @acc = Hash.new
    (1..4).each { |counter| @acc[counter] = WidgetableMixin.create }
  end
  
  def test_simple_values
    acc1 = @acc[1]
    assert clip = acc1.clip!(:user => @user)
    assert_equal acc1.title, clip.wid_name
    assert_equal clip.wid_name, clip.full_name
    clip.name = 'Headliner'
    assert_equal "Headliner: untitled", clip.full_name
    assert_equal acc1.content, clip.wid_content
    assert_equal acc1.user, clip.wid_user
    assert_equal "/mixin", clip.wid_partial(''), clip.widgetable_type
    assert_equal "/mixin_default", clip.wid_partial('', 'default')
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
    assert !acc1.clips.placed.include?(clip)
    assert acc1.clips.unplaced.include?(clip)
    
    acc2 = @acc[2]
    assert clip2 = acc2.clip!(:user => @user, :position => 55)
    assert_equal 55, clip2.position
    
    assert clip.place!(4)
    assert_equal 4, clip.position
    assert acc1.clips.placed.include?(clip)
    assert !acc2.clips.unplaced.include?(clip)
    assert clip2.place!(4)
    assert_equal 4, clip2.position
    assert !clip.reload.placed?
  end
  
  def test_unclip
    acc1 = @acc[1]
    assert acc1.clip!(:user => @user)
    assert acc1.clip_for?(@user)
    assert clip = acc1.clip_for(@user)
    assert !clip.placed?
    assert_raise(ArgumentError) { acc1.unclip! }
    assert acc1.unclip!(:user => @user)
    assert !acc1.clip_for?(@user)
    assert_nil acc1.clip_for(@user)
  end
  
  def test_displacement
    acc1 = @acc[1]
    acc2 = @acc[2]
    assert clip = acc1.clip!(:user => @user)
    position = clip.position
    assert clip2 = acc2.clip!(:user => @user, :position => position)
    assert_nil clip.reload.position
    assert_equal position, clip2.position
  end

  def test_picture
    acc1 = @acc[1]
    assert clip = acc1.clip!(:user => @user)
    assert_nil acc1.picture
  end

end
