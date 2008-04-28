class Comment < ActiveRecord::Base
  serialize :reference_ids
  acts_as_accessible

  belongs_to :user
  belongs_to :commentable, :polymorphic => true, :inherits_layout => true
  validates_presence_of :user_id, :unless => lambda{|comment| !SITE[:disable_anonymous] && comment.commentable &&
                                                              comment.commentable.allows_anonymous_comments? && !comment.email.blank? } # For anonymous comments
  
  after_create :increment_counter#, :send_notification
  
  # For widget
  alias_attribute :content, :body
  def name; self.body.to_s[0..10] + '...'; end
  
  def to_path(for_associated=false)
    { :"#{for_associated ? 'comment_id' : 'id'}" => self.to_param }.merge(self.commentable.nil? ? {} : self.commentable.to_path(true))
  end
  
  def path_name_prefix
    [ self.commentable.path_name_prefix, 'comment' ].join('_')
  end
  
  def reference_ids
    self[:reference_ids] || []
  end
  
  def references
    @references ||= if !self.commentable.loaded?
      self.commentable.comments.find(self.reference_ids).sort_by {|com| self.reference_ids.index(com.id) }
    else
      if self.commentable.comments.loaded?
        self.commentable.comments.select{|com| self.reference_ids.include?(com.id) }.sort_by {|com| self.reference_ids.index(com.id) }
      else
        self.commentable.comments.find(self.reference_ids).sort_by {|com| self.reference_ids.index(com.id) }        
      end
    end
  end
  
  # comment[:references] = "@47, @8, @92"
  def references=(list, with_save=false)
    @references = nil
    self.reference_ids = list.split(/\s*,\s*/).select{|mark| mark.is_a?(String) && mark[0].chr == "@" }.map {|str| str[1..-1].to_i }
    self.save if with_save
  end
  
  def add_references(*comment_ids)
    
  end
  
  def anonymous?
    self.user.nil?
  end
  
  def accessible_by?(user=nil)
    (self.user == user || self.commentable.accessible_by?(user) rescue true) && self.rule.accessible_by?(user)
  end
  
  def editable_by?(user=nil)
    user && (self.commentable.editable_by?(user) || super)
  end

  #######
  private
  #######
  def increment_counter
    self.commentable.increment!(:comments_count) if self.commentable.respond_to?(:comments_count)
  end
  
  def send_notification
    Notifier.deliver_comment_notification(self)
  end
end
