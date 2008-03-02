require File.dirname(__FILE__) + "/../../../../test/test_helper"

class Mixin < ActiveRecord::Base
end

class ResponsibleMixin < Mixin
  acts_as_responsible
  belongs_to :user

  def self.table_name() "articles" end
end

class ResponsibleMixinSub1 < ResponsibleMixin
end

class ResponsibleMixinSub2 < ResponsibleMixin
end


class ResponsibleTest < Test::Unit::TestCase    
  
  def setup
    @user = users(:colin)
    @acc = Hash.new
    (1..4).each { |counter| @acc[counter] = ResponsibleMixin.create }
  end
  
  def test_report
    acc1 = @acc[1]
    assert !acc1.reported_with?
    assert rep = acc1.report(:user => @user)
    assert rep.variation == RESPONSE_PREFS[:report][:questionable]
    assert 1, acc1.num_reported_with
    assert acc1.reported_with?
    assert !acc1.reported_with?(:dupe)
    assert acc1.report(:user => @user)
    assert_equal 2, acc1.num_reported_with
    assert acc1.report(:dupe, :user => @user)
    assert_equal 3, acc1.num_reported_with
    assert_equal 1, acc1.num_reported_with(:dupe)
    assert acc1.reported_with?(:dupe)
  end
  
  def test_favorite
    acc1 = @acc[1]
    assert !acc1.favorited_by?(@user.id)
    assert acc1.favorit(@user.id)
    assert_equal 1, Favorite.count
    assert acc1.favorited_by?(@user.id)
  end
  
  def test_comment_with
    acc1 = @acc[1]
    assert acc1.comment_with(:body => "hello")
    assert !acc1.comments.nil?
  end
  
  def test_rate_with
    acc1 = @acc[1]
    assert acc1.rate_with(:user => @user)
  end

end
