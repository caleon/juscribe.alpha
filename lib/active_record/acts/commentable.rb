module ActiveRecord::Acts::Commentable
  def self.included(base)
    base.extend(ClassMethods)  
  end

  module ClassMethods
    def acts_as_commentable(options = {})
      with_options :class_name => 'Comment', :as => :commentable do |comment|
        comment.has_many :comments, :order => 'comments.position ASC'
        comment.has_many :latest_comments, :order => 'comments.id DESC', :limit => 5
      end   
      
      include ActiveRecord::Acts::Commentable::InstanceMethods
      extend ActiveRecord::Acts::Commentable::SingletonMethods
    end
  end
  
  module SingletonMethods
    
  end
  
  module InstanceMethods
    # These functionalities depend on PermissionRule model.
    # Seems like these following functionality will depend on one or two columns on each commentable model.
    def allows_comments?
      !SITE[:disable_comments] && (self.rule.get_option(:comments).nil? ? default_allows_comments? : self.rule.get_option(:comments)) rescue true
    end
    
    def allow_comments!; self.rule.set_option!(:comments, true) unless self.allows_comments?; end
    def disallow_comments!; self.rule.set_option!(:comments, false) if self.allows_comments?; end
    
    def allows_anonymous_comments?
      self.allows_comments? && !SITE[:disable_anonymous_comments] && (self.rule.get_option(:anonymous_comments).nil? ? default_allows_anonymous_comments? : self.rule.get_option(:anonymous_comments)) rescue false
    end
    
    def allow_anonymous_comments!
      self.allow_comments! # Doesn't make sense otherwise.
      self.rule.set_option!(:anonymous_comments, true) unless self.allows_anonymous_comments?
    end
    def disallow_anonymous_comments!; self.rule.set_option!(:anonymous_comments, false) if self.allows_anonymous_comments?; end
    
    # The following are for usage with forms.
    def allow_comments=(input)
      if !self.allows_comments? && [ true, 'true', 't', '1', 1, 'y', 'yes' ].include?(input)
        self.allow_comments!
      elsif self.allows_comments? && ![ true, 'true', 't', '1', 1, 'y', 'yes' ].include?(input)
        self.disallow_comments!
      end
    end
    
    def allow_anonymous_comments=(input)
      if !self.allows_anonymous_comments? && [ true, 'true', 't', '1', 1, 'y', 'yes' ].include?(input)
        self.allow_anonymous_comments!
      elsif self.allows_anonymous_comments? && ![ true, 'true', 't', '1', 1, 'y', 'yes' ].include?(input)
        self.disallow_anonymous_comments!
      end
    end
    
    def allow_comments; self.allows_comments?; end
    def allow_anonymous_comments; self.allows_anonymous_comments?; end
    
    def chrono_comments
      @chrono_comments ||= self.comments.find(:all, :order => 'comments.id ASC')
    end
    
    def correct_comment_positions!
      chrono_comments.each do |comment|
        comment.update_attribute(:position, chrono_comments.index(comment) + 1)
      end
    end
    
    def correct_replies_count!
      self.comments.each {|comment| comment.correct_replies_count! }
    end
    
    private
    # The following are for cases when the values are not set in permission_rules.options column.
    def default_allows_comments?; true; end
    def default_allows_anonymous_comments?; true; end
  end
end
