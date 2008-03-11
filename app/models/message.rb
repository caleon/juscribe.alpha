class Message < ActiveRecord::Base
  belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id', :include => :primary_picture
  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id', :include => :primary_picture
  
  validates_associated :recipient, :sender
  validates_presence_of :subject, :body, :sender_id, :recipient_id
  validates_with_regexp :subject
  validates_with_regexp :body
    
  def subject
    self[:subject] || "(no subject)"
  end
  
  def draft?; !self.sent?; end
  
  def read_it!; self.update_attribute(:read, true) unless self.read?; end
  def unread_it!; self.update_attribute(:read, false) unless !self.read?; end
  
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
  
  def accessible_by?(user) # This class does not acts_as_accessible. These are totally custom.
    user.admin? || [ self.sender, self.recipient ].include?(user)
  end
  
  def editable_by?(user)
    user.admin? || (self.sender == user && !self.sent? && !self.read?)
  end
end
