require File.dirname(__FILE__) + '/../test_helper'

class MessageTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_default_fields
    msg = Message.new(:body => 'hello world!')
    assert_nil msg[:subject]
    assert_equal "(no subject)", msg.subject
  end
  
  def test_validations
    msg = Message.new
    assert !msg.valid?
    msg.body = "   "
    assert !msg.valid?
    msg.body = "     a "
    assert !msg.valid?
    msg.body = "    aaa "
    assert !msg.valid?
    msg.body.strip!
    msg.subject = "    aaa "
    assert !msg.valid?
    msg.subject.strip!
    msg.recipient = users(:keira)
    assert !msg.valid?
    msg.sender = users(:colin)
    assert msg.valid?
    msg.sender = User.create(:nick => 'moy')
    assert !msg.valid?
  end
  
  def test_transmit
    orig_mail_count = ActionMailer::Base.deliveries.size
    assert msg = Message.create(:body => 'testing transmission', :sender => users(:colin), :recipient => users(:keira))
    assert msg.transmit
    assert_equal true, msg.sent
    assert_equal orig_mail_count + 1, ActionMailer::Base.deliveries.size
    
    assert !msg.transmit
    assert_equal 1, msg.errors.size
  end
  
  def test_accessible_by_check
    msg = Message.create(:body => 'La la la la la', :subject => 'Hello world', :sender => users(:colin), :recipient => users(:nana))
    assert msg.valid?
    assert msg.accessible_by?(users(:colin))
    assert msg.accessible_by?(users(:nana))
    assert !msg.accessible_by?(users(:keira))
    assert !msg.accessible_by?(users(:megan))
    
    msg2 = Message.create(:body => 'la la la la', :subject => 'hello again', :sender => users(:nana), :recipient => users(:keira))
    assert msg2.valid?
    assert msg2.accessible_by?(users(:nana))
    assert msg2.accessible_by?(users(:keira))
    assert msg2.accessible_by?(users(:wheel))
  end
  
  def test_editable_by_check
    msg = Message.create(:body => 'boajsdlfajdsf', :subject => 'asdfkjadsf', :sender => users(:keira), :recipient => users(:megan))
    assert msg.valid?
    assert msg.editable_by?(users(:wheel))
    assert msg.editable_by?(users(:keira))
    assert !msg.editable_by?(users(:megan))
    msg.read_it!
    assert !msg.editable_by?(users(:keira))
    msg.unread_it!
    assert msg.editable_by?(users(:keira))
    assert msg.transmit
    assert !msg.editable_by?(users(:keira))
  end

end
