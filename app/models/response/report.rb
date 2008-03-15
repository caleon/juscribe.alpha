class Report < Response
  # TODO after_create :send_notification
  
  VARIATIONS = { :dupe         =>  1,
                 :explicit     =>  2,
                 :questionable =>  3,
                 :banned       =>  4,
                 :incorrect    =>  5 }
  
  private
  # TODO: need to make these extendable, instead of hardcoding mailer methods
  def send_notification
    if var = VARIATIONS.invert[self.variation]
      Notifier.deliver_report_notification(var, self)
    else
      raise Notifier::NotifierError, "Invalid Report type for (#{self.internal_name}). Cannot send notifications."
    end
  end
end
