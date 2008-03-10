require File.dirname(__FILE__) + '/../test_helper'

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
    (1..4).each { |counter| @acc[counter] = ResponsibleMixin.create(:user => @user) }
  end
  
  def test_invalidation
    acc1 = @acc[1]
    assert rep = acc1.report(:user => @user)
    id = rep.id
    assert rep.invalidate!
    assert_raise(ActiveRecord::RecordNotFound) { Response.find(id) }
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
  
  def test_report_notification
    orig_mail_count = ActionMailer::Base.deliveries.size
    acc1 = @acc[1]
    assert !acc1.reported_with?
    assert rep = acc1.report(:user => @user)
    assert_nothing_raised(Notifier::NotifierError) { rep.send(:send_notification) }
    assert_equal orig_mail_count + 1, ActionMailer::Base.deliveries.size
    rep.update_attribute(:variation, 200)
    assert_raise(Notifier::NotifierError) { rep.send(:send_notification) }
    assert_equal orig_mail_count + 1, ActionMailer::Base.deliveries.size
  end
  
  def test_favorite
    assert Favorite.general.is_a?(Array)
    assert Favorite.general.size <= 5
    acc1 = @acc[1]
    assert !acc1.favorited_by?(@user.id)
    assert acc1.favorit(@user.id)
    assert_equal 1, Favorite.count
    assert acc1.favorited_by?(@user.id)
    fav = acc1.favorit(@user)
    assert fav.is_a?(Favorite) && !fav.valid?
    assert_raise(ActiveRecord::RecordInvalid) { fav.save! }
  end
  
  def test_comment_with
    acc1 = @acc[1]
    assert com = acc1.comment_with(:body => "hello", :user => users(:colin))
    assert com.is_a?(Comment) && !com.new_record?, com.errors.inspect
    assert !acc1.comments.nil?
    assert com.send(:send_notification)
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert com2 = acc1.comment_with(:body => 'hello again', :original => com)
    assert com2.send(:send_notification)
    assert_equal 2, ActionMailer::Base.deliveries.size
  end
  
  def test_rate_with
    acc1 = @acc[1]
    assert rating = acc1.rate_with(:user => @user)
    rating2 = acc1.rate_with(:user => @user)
    assert rating2.new_record? && !rating2.valid? && !rating2.errors.blank?
    assert_equal acc1, rating.responsible
    assert_not_nil rating.responsible[:user_id]
    assert_nothing_raised(ActiveRecord::RecordNotFound) { @person = User.find(rating.responsible[:user_id]) }
    assert_not_nil acc1.user
    assert_equal acc1.user, @person
    assert @person.wants_notifications_for?(:rating)
    assert_nothing_raised(Notifier::NotifierError) { rating.send(:send_notification) }
    assert_equal 3, ActionMailer::Base.deliveries.size
    @person.set_notification_for(:rating, true)
    assert @person.wants_notifications_for?(:rating)
    assert_nothing_raised(Notifier::NotifierError) { rating.send(:send_notification, @person) }
    assert_equal 4, ActionMailer::Base.deliveries.size
    @person.set_notification_for(:rating, false)
    assert !@person.wants_notifications_for?(:rating), @person[:notify].inspect
    assert_raise(Notifier::NotifierError) { rating.send(:send_notification, @person) }
  end

end
