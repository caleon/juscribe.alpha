class Report < Response
  #after_create :send_notification
  
  private
  # TODO: need to make these extendable, instead of hardcoding mailer methods
  def send_notification
    case RESPONSE_PREFS[:report].invert[self.variation]
    when :copyright
      #TODO: cc copyright management team
      Notifier.deliver_infringer_notification(self.id)
      Notifier.deliver_infringee_notification(self.id) if self.secondary_id
    when :dupe
      Notifier.deliver_duper_notification(self.id)
      Notifier.deliver_dupee_notification(self.id) if self.secondary_id
    when :explicit
      Notifier.deliver_explicit_notification(self.id)
    when :questionable
      Notifier.deliver_questionable_notification(self.id)
    else
      raise NotifierError, "Invalid Report type for (#{self.internal_name}). Cannot send notifications."
    end
  end
end
