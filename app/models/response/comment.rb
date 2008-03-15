class Comment < Response
  acts_as_accessible
  
  belongs_to :original, :class_name => "Comment", :foreign_key => :secondary_id
  has_many :followups, :class_name => "Comment", :as => :original, :foreign_key => :secondary_id
  
  #after_create :send_notification
  
  def to_path(for_associated=false)
    if self.user.nil?
      { :"#{for_associated ? 'comment_id' : 'id'}" => self.to_param }
    else
      { :user_id => self.user.to_param, :"#{for_associated ? 'comment_id' : 'id'}" => self.to_param }
    end
  end
  
  def to_polypath
    { :id => self.to_param }.merge(self.responsible.nil? ? {} : self.responsible.to_path(true))
  end
  
  def accessible_by?(user=nil)
    (self.responsible.accessible_by?(user) rescue true) && self.rule.accessible_by?(user)
  end
    
  #######
  private
  #######
  
  def send_notification
    Notifier.deliver_comment_notification(self)
  end
end
