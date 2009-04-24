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
  
  def comment_notification_to_commentable(comment)    
    user = comment.commentable.user
    name = comment.user ? comment.user.full_name : comment.nick
    
    subject %{#{name} commented on your #{comment.commentable_type.humanize.downcase}: #{comment.commentable.display_name}}
    content_type "text/plain"
    recipients user.email_address
    from "#{APP[:name].capitalize}<#{APP[:mailer_from]}>"
    sent_on Time.now
    body :user => user, :comment => comment, :name => name
  end
  
  def comment_notification_to_orig_comment(comment, index=0)
    orig_comment = comment.references[index]    
    orig_name = orig_comment.user ? orig_comment.user.full_name : orig_comment.nick
    name = comment.user ? comment.user.full_name : comment.nick
    orig_recipient = orig_comment.user ? orig_comment.user.email_address : "#{orig_comment.nick}<#{comment.email}>"
    
    content_type "text/plain"
    subject %{#{name} responded to your comment on #{comment.commentable_type.humanize.downcase}: #{comment.commentable.display_name}}
    recipients orig_recipient
    from "#{APP[:name].capitalize}<#{APP[:mailer_from]}>"
    sent_on Time.now
    body :comment => comment, :name => name, :orig_name => orig_name
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
