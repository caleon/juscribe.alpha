require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase
  # Replace this with your real tests.

  def test_start_and_end
    event = Event.create(:name => 'shindig', :user => users(:colin))
    assert_nil event.begins_at
    assert_nil event.ends_at
    assert time = event.begin!
    assert_equal time, event.begins_at
    assert time2 = event.end!
  end
  
  def test_weird_stoppage
    event = Event.create(:name => 'shindig', :user => users(:colin))
    event.update_attribute(:begins_at, 1.hour.from_now)
    assert_not_nil event.begins_at
    assert_nil event.ends_at
    assert time = event.end!
    assert_equal event.begins_at, event.ends_at
    
    event2 = Event.create(:name => 'party', :user => users(:colin))
    event2.update_attribute(:ends_at, 1.hour.ago)
    assert_not_nil event2.ends_at
    assert_nil event2.begins_at
    assert time2 = event2.begin!
    assert_equal event2.begins_at, event2.ends_at 
  end
  
  def test_invite
    event = Event.create(:name => 'orgy', :user => users(:colin))
    event.invite!(users(:keira), users(:megan), users(:alessandra))
    assert_equal 1, ActionMailer::Base.deliveries.size
  end
  
end
