class Event < ActiveRecord::Base
  include PluginPackage
  
  belongs_to :user
  has_many :picture, :as => :depictable
  has_many :entries, :order => 'created_at DESC'
    
  validates_presence_of :user_id, :name
  validates_length_of :name, :in => (3..20)
  validates_with_regexp :name
  
  def to_s
    self.name
  end
  
  def to_path
    if self.user
      { :user_id => self.user.nick, :id => self.to_param }
    else
      { :id => self.to_param }
    end
  end
  
  def begin!(time=Time.now, force=false)
    if !self.begins_at.nil? && !force
      self.errors.add(:begins_at, "is already set")
      return false
    else
      self.update_attribute(:begins_at, time)
      if !self.begins_at.nil?
        self.end!(time, true) if self.ends_at < time rescue true
        return time
      else
        self.errors.add(:begins_at, "could not be set")
        return false
      end
    end
  end
  
  def end!(time=Time.now, force=false)
    if !self.ends_at.nil? && !force
      self.errors.add(:ends_at, "is already set")
      return false
    else
      self.update_attribute(:ends_at, time)
      if !self.ends_at.nil?
        self.begin!(time, true) if self.begins_at > time rescue true
        return time
      else
        self.errors.add(:ends_at, "could not be set")
        false
      end
    end
  end
  
  # TODO: prevent multiple duplicate mailings
  def invite!(*users)
    opts = users.extract_options!
    users = users.shift if users.first.is_a?(Array)
    rule = self.create_rule if self.rule.nil?
    self.rule.whitelist!(:user, *users) if self.user == opts[:from]
    Notifier.deliver_event_invitation(users, :from => opts[:from])
  end
  
  def share!(*users)
    opts = users.extract_options!
    users = users.shift if users.first.is_a?(Array)
    rule = self.rule
    rule.whitelist!(:user, *users) if self.user == opts[:from]
    # TODO: prevent multiple duplicate mailings
    # TODO: filter out users based on wants_notifications_for? in Notifier class.
    Notifier.deliver_event_share_notification(users, :from => opts[:from])
  end
    
end
