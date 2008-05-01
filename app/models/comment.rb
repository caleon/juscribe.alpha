class Comment < ActiveRecord::Base
  serialize :reference_ids
  acts_as_accessible

  belongs_to :user
  belongs_to :commentable, :polymorphic => true, :inherits_layout => true
  acts_as_list :scope => :commentable
  
  validates_presence_of :user_id, :unless => lambda{|comment| !SITE[:disable_anonymous] && comment.commentable && comment.commentable.allows_anonymous_comments? && !comment.email.blank? } # For anonymous comments
  
  after_create :increment_counter#, :send_notification
  
  # For widget
  alias_attribute :content, :body
  alias_attribute :scoped_id, :position
  def name; self.body.to_s[0..10] + '...'; end
  
  def to_path(for_associated=false)
    { :"#{for_associated ? 'comment_id' : 'id'}" => self.to_param }.merge(self.commentable.nil? ? {} : self.commentable.to_path(true))
  end
  
  def path_name_prefix
    [ self.commentable.path_name_prefix, 'comment' ].join('_')
  end
  
  def reference_ids
    self[:reference_ids] || [] # will not include paragraph hash here.
  end
  
  # This needs to get references of its references until there is no more...
  def references
    @references ||= Comment.find(:all, :conditions => ["(comments.commentable_type = ? AND comments.commentable_id = ?) AND comments.position IN (?)", self.commentable_type, self.commentable_id, self.reference_ids], :order => 'comments.position ASC')
  end
  
  # comment[:references] = "@47, @8, @92"
  def references=(list, with_save=false)
    @references = nil
    list = list.gsub(/,/, ' ')
    list.gsub(/\s+([a-z0-9]{7})\s*/, ' ')
    self.paragraph_hash = $1
    self.reference_ids = list.split(/\s+/).select{|mark| mark.is_a?(String) && mark.match(/^@\d+$/) }.map {|str| str[1..-1].to_i }.reject{|id| self.position == id }
    self.save if with_save
  end
  
  def add_references(*comment_ids)
    
  end
  
  def anonymous?
    self.user.nil?
  end
  
  def deleted?
    self.body.blank?
  end
  
  def accessible_by?(user=nil)
    (self.user == user || self.commentable.accessible_by?(user) rescue true) && self.rule.accessible_by?(user)
  end
  
  def editable_by?(user=nil)
    user && (self.commentable.editable_by?(user) || super)
  end
  
  def nullify!(user=nil)
    self.update_attribute(:body, nil) if self.editable_by?(user)
  end
  
  def correct_replies_count!
    self.references.each {|ref| ref.increment!(:replies_count) } if !self.references.empty?
  end

  #######
  private
  #######
  def increment_counter
    self.commentable.increment!(:comments_count) if self.commentable.respond_to?(:comments_count)
    self.correct_replies_count!
  end
  
  def send_notification
    Notifier.deliver_comment_notification(self)
  end
end
