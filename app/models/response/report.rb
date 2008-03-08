class Report < Response
  #after_create :send_notification
  
  private
  # TODO: need to make these extendable, instead of hardcoding mailer methods
  def send_notification
    if var = RESPONSE_PREFS[:report].invert[self.variation]
      Notifier.report_notification(var, self)
    else
      raise NotifierError, "Invalid Report type for (#{self.internal_name}). Cannot send notifications."
    end
  end
end
