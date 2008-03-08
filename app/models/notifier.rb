class Notifier < ActionMailer::Base
  
  def setup_email
    @from = APP[:mailer_from]
    @sent_on = Time.now
  end
  
  def multipart_alternative(sent_at = Time.now)
    @subject = 'Notifier#multipart_alternative'
    @body = {}
    @recipients = ''
    @from = ''
    @sent_on = sent_at
    @headers = {}
  end
  
  def password_change_notification(user)
    
  end
  
  def email_change_notification(user)
    
  end
  
  def comment_notification(comment)
    if comment.secondary_id && orig_comment = comment.original
      @user = orig_comment.user
      @subject = "Your comment has a responding comment"
      # URLS to be generated according to routes in VIEW
      #@body["url"] = generate_url_for(comment)
    else
      @user = comment.responsible.user
      @subject = "Your #{comment.responsible_type.downcase} has a comment"
      #@body["url"] = generate_url_for(comment.responsible)
    end
  end
    
  def message_notification(msg_record)
    
  end
  
  def rating_notification(rating_record)
    
  end
  
  def report_notification(*args)
    
  end
  
  def event_invitation
    
  end
  
  def event_share_notification
    
  end
  
  def friendship_request(*args)
    
  end
  
  def group_disband_notification(group)
    
  end
  
  def group_leave_notification(*args)
    
  end
  
  def event_invitation(*args)
    opts = args.extract_options!
    # args is an array of User objects. BCC the result of map(:&email_address)
  end
  
  def event_share_notification(*args)
    opts = args.extract_options!
    # args is an array of User objects. BCC the result of map(&:email_address)
  end
  
  def abuse_notification
    
  end
  
  class NotifierError < StandardError; end
  
end
