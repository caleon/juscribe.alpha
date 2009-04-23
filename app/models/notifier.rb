class Notifier < ActionMailer::Base
  # TODO: setup Postman intermediary that decides whether to use Notifier or
  # in-system Message model.
  
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
      user = orig_comment.user
      subject "Your comment has a responding comment"
      # URLS to be generated according to routes in VIEW
      #@body["url"] = generate_url_for(comment)
    else
      user = comment.commentable.user
      subject "Your #{comment.commentable_type.downcase} has a comment"
      #@body["url"] = generate_url_for(comment.responsible)
    end
    recipients @user.email
    from "Juscribe<no-reply@juscribe.com>"
    sent_on Time.now
    body { :comment => comment, :user => user }
    content_type "text/plain"
  end
    
  def message_notification(msg_record)
    
  end
  
  def event_invitation
    
  end
  
  def event_share_notification
    
  end
  
  def friendship_request(*args)
    
  end
  
  def group_invitation(opts)
    to_user = opts[:to_user]
    from_user = opts[:from_user]
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
