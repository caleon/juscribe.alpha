class Notifier < ActionMailer::Base
  # TODO: setup Postman intermediary that decides whether to use Notifier or
  # in-system Message model.
  
  def setup_email
    @from = "#{APP[:name].capitalize}<#{APP[:mailer_from]}>"
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
  
  def comment_notification_to_commentable(comment)
    setup_email
      
    commenter = comment.commenter
    commentable = comment.commentable
    user = commentable.user
        
    content_type "text/plain"
    subject %{#{commenter.full_name} commented on "#{commentable.display_name}"}
    recipients user.email_address
    body :comment => comment, :commenter => commenter,
         :commentable => commentable, :user => user
  end
  
  def comment_notification_to_orig_comment(comment, index=0)
    setup_email
    
    commenter = comment.commenter
    commentable = comment.commentable
    orig_comment = comment.references[index]
    orig_commenter = orig_comment.commenter

    content_type "text/plain"
    subject %{#{commenter.full_name} responded to your comment on "#{commentable.display_name}"}
    recipients orig_commenter.email_address
    body :comment => comment, :commenter => commenter,
         :orig_comment => orig_comment, :orig_commenter => orig_commenter
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
