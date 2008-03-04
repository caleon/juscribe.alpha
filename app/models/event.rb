class Event < ActiveRecord::Base
  include PluginPackage
  
  belongs_to :user
  has_many :picture, :as => :depictable
  has_many :entries, :order => 'created_at DESC'
    
  validates_presence_of :user_id, :title
  
  def begin!(time=Time.now, force=false)
    if !self.begins_at.nil? && !force
      self.errors.add(:begins_at, "is already set")
      return false
    elsif self.update_attribute(:begins_at, time)
      self.end!(time, true) if self.ends_at < time rescue true
      return time
    else
      self.errors.add(:begins_at, "could not be set")
      return false
    end
  end
  
  def end!(time=Time.now, force=false)
    if !self.ends_at.nil? && !force
      self.errors.add(:ends_at, "is already set")
      return false
    elsif self.update_attribute(:ends_at, time)
      self.begin!(time, true) if self.begins_at > time rescue true
      return time
    else
      self.errors.add(:ends_at, "could not be set")
      false
    end
  end
  
  # TODO: neither of the following currently have the FROM part.
  # TODO: prevent multiple duplicate mailings
  def invite!(*users)
    opts = users.extract_options!
    users = users.shift if users.first.is_a?(Array)
    rule = self.create_rule if self.rule.nil?
    self.rule.whitelist!(:user, *users) if self.user == opts[:from]
    Notifier.deliver_event_invitation(users, :from => opts[:from])
  end
  
  def share!(*users)
    users = users.shift if users.first.is_a?(Array)
    rule = self.create_rule if self.rule.nil?
    self.rule.whitelist!(:user, *users) if self.user == opts[:from]
    # TODO: prevent multiple duplicate mailings
    # TODO: filter out users based on wants_notifications_for? in Notifier class.
    Notifer.deliver_event_share_notification(users, :from => opts[:from])
  end
    
end
