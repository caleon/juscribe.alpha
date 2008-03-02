class Comment < Response
  belongs_to :commentable, :polymorphic => true, :counter_cache => true
  belongs_to :original, :class_name => "Comment", :foreign_key => :secondary_id
  has_many :followups, :class_name => "Comment", :as => :original, :foreign_key => :secondary_id
  
  #after_create :send_notification
  
  #######
  private
  #######
  
  def send_notification
    Notifier.deliver_comment_notification(self.id)
    Notifier.deliver_original_comment_notification(self.id, self.secondary_id) if self.secondary_id
  end
end
