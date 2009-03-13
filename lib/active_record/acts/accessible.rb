#require_dependency 'permission' # Holy shit. this fixed it.
module ActiveRecord::Acts::Accessible #:nodoc:  
  def self.included(base)
#    base.module_eval <<-EOS
#      def self.accessible?; false; end
#      def accessible?; false; end
#    EOS
    base.extend(ClassMethods)  
  end

  module ClassMethods
    def acts_as_accessible(options={})
      write_inheritable_attribute(:acts_as_accessible_options, {
        :accessible_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s,
        :from => options[:from], # this might be needed to auto create rules
        :destroy => options[:destroy]
      })
    
      class_inheritable_reader :acts_as_accessible_options
    
      has_one :permission, :as => :permissible, :include => :permission_rule, :dependent => :destroy

      include ActiveRecord::Acts::Accessible::InstanceMethods
      extend ActiveRecord::Acts::Accessible::SingletonMethods
    end
  end

  module SingletonMethods
    def accessible?; true; end
  end

  module InstanceMethods
    # example: article.create_rule(:title => 'for friends', :description => 'blah blah blah', :allow => {:user => 2}, :deny => {})
    def public?; self.rule.public?; end
    def private?; self.rule.private?; end
    def protected?; self.rule.protected?; end
  
    # override this in models with a 'super'
    def accessible_by?(user=nil)
      # The rescue is in case this module is attached to a
      # model which does not have a #user method.
      (self.user == user rescue true) || (user && self.editable_by?(user)) ||
      self.rule.accessible_by?(user)
    end

    def editable_by?(user)
      (user.admin? || self.user == user rescue false) ||
      self.rule.bosses[:user].include?(user ? user.id : nil) ||
      self.rule.bosses[:group].include?(user.group_ids) rescue false
      # FIXME: pulling user.group_ids each time will be taxing on DB. cache
      # the array of group_ids per user in a serializable array or something.
      # TODO: Make unit tests for bosses addition
    end
  
    def rule
      prule = self.permission.permission_rule
      raise ActiveRecord::RecordNotFound if prule.nil?
      prule
    rescue NoMethodError, ActiveRecord::RecordNotFound
      self.create_rule(:user => self.user)
    end
      
    def create_rule(attrs={})
      attrs[:user_id] = self[:user_id] || attrs[:user_id] || (attrs.delete(:user).id if attrs[:user]) rescue nil
      raise ArgumentError, 'Need to supply a user or user_id.' unless attrs[:user_id]
      self.rule = PermissionRule.create!(attrs)          
    end
  
    def rule=(permission_rule)
      if p = Permission.find(:first, :conditions => ["permissible_type = ? AND permissible_id = ?", self.class.to_s, self.id])
        p.update_attribute(:permission_rule_id, permission_rule.id)
      else
        p = Permission.create
        self.permission = p
        p.save
      end
      permission_rule.permissions << p
      permission_rule
    end
  
    def accessible?; true; end
  end
end
