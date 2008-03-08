class Message < ActiveRecord::Base
  belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'
  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id'
  
  validates_associated :recipient, :sender
  validates_presence_of :subject, :body, :sender_id, :recipient_id
  validates_format_of :subject, :with => /^[^\s].+[^\s]$/i
  validates_format_of :body, :with => /^[^\s].+[^\s]$/i
    
  def subject
    self[:subject] || "(no subject)"
  end
  
  def transmit # can't do #send
    if !self.sent?
      self.sent = true
      self.save
      Notifier.deliver_message_notification(self)
      self
    else
      self.errors.add_to_base("Your message has already been sent.")
      return false
    end
  end
end
