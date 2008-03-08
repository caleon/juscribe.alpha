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

end
