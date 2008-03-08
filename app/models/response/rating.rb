class Rating < Response
  validates_uniqueness_of :user_id, :scope => [:responsible_type, :responsible_id]
  
  #after_create :send_notification
  
  private
  def send_notification(user=nil)
    if self.responsible && self.responsible[:user_id] && (user ||= User.find(self.responsible[:user_id])) && user.wants_notifications_for?(:rating)
      Notifier.deliver_rating_notification(self)
    else
      raise NotifierError, "Unable to set target for rating (#{self.internal_name}) notification."
    end
  end
end
