class Message < ActiveRecord::Base
  belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'
  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id'
  
  validates_associated :recipient, :sender
  validates_presence_of :body
    
  def subject
    self[:subject] || "(no subject)"
  end
  
  def send
    if !self.sent?
      self.sent = true
      self.save
    else
      self.errors.add_to_base("Your message has already been sent.")
      return false
    end
  end
end
