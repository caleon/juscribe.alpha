class Comment < ActiveRecord::Base
  acts_as_accessible

  belongs_to :user
  belongs_to :commentable, :polymorphic => true
  belongs_to :original, :class_name => "Comment", :foreign_key => :secondary_id
  has_many :followups, :class_name => "Comment", :as => :original, :foreign_key => :secondary_id
  validates_presence_of :user_id
  
  # For widget
  alias_attribute :content, :body
  def name; self.body.to_s[0..10] + '...'; end
  
  #after_create :send_notification
  
  def to_path(for_associated=false)
    if self.user.nil?
      { :"#{for_associated ? 'comment_id' : 'id'}" => self.to_param }
    else
      { :user_id => self.user.to_param, :"#{for_associated ? 'comment_id' : 'id'}" => self.to_param }
    end
  end
  
  def to_polypath
    { :id => self.to_param }.merge(self.commentable.nil? ? {} : self.commentable.to_path(true))
  end
  
  def accessible_by?(user=nil)
    (self.user == user || self.commentable.accessible_by?(user) rescue true) && self.rule.accessible_by?(user)
  end
  
  def editable_by?(user=nil)
    user && (self.commentable.editable_by?(user) || super)
  end
  
  def invalidate!
    self.destroy
  end

  #######
  private
  #######
  
  def send_notification
    Notifier.deliver_comment_notification(self)
  end
end
