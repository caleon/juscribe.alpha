class Message < ActiveRecord::Base
  belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'#, :include => :primary_picture
  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id'#, :include => :primary_picture
  
  #validates_associated :recipient, :sender
  validates_presence_of :subject, :body, :sender_id, :recipient_id
  validates_with_regexp :subject
  validates_with_regexp :body
  
  after_create :deliver_message_notification
    
  def subject
    self[:subject] || "(no subject)"
  end
  
  def recipient=(user_or_nick)
    user = user_or_nick.is_a?(User) ? user_or_nick : User.find_by_nick(user_or_nick)
    self.recipient_id = user.id
  rescue
    raise ArgumentError, "Expected User or nick: got #{user_or_nick.class} instead."
  end
  
  def read_it!; self.update_attribute(:read, true) unless self.read?; end
  def unread_it!; self.update_attribute(:read, false) unless !self.read?; end
    
  def accessible_by?(user) # This class does not acts_as_accessible. These are totally custom.
    user.admin? || [ self.sender, self.recipient ].include?(user)
  end
  
  def editable_by?(user)
    user.admin? || (self.sender == user && !self.read?)
  end
  
  private
  def deliver_message_notification
    Notifier.deliver_message_notification(self)
  end
end
