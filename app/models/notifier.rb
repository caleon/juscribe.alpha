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
  
  def comment_notification(comment_id, orig_comment_id=nil)
    comment = Comment.find(comment_id, :include => (orig_comment_id ? {:original => :user} : {:responsible => :user}))
    if orig_comment_id && orig_comment = comment.original
      @user = orig_comment.user
      @subject = "Your comment has a responding comment"
      @body["url"] = generate_url_for(comment)
    else
      @user = commentable.user
      @subject = "Your #{commentable.class.to_s.downcase} has a comment"
      @body["url"] = generate_url_for(commentable)
    end
  end
  
  def rating_notification()
    
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
  
end
