require 'digest/sha2'
require 'friendship'

class User < ActiveRecord::Base
  acts_as_taggable
  acts_as_accessible
  acts_as_responsible
  acts_as_widgetable
      
  has_many :articles
  has_many :entries
  has_many :songs
  has_many :events
  has_many :projects
  has_many :taggings
  has_many :owned_pictures, :class_name => 'Picture'
  has_many :pictures, :as => :depictable
  has_many :memberships
  has_many :groups, :through => :memberships
  has_many :owned_groups, :class_name => 'Group'
  has_many :widgets, :order => :position
  has_many :favorite, :class_name => 'Favorite', :order => 'id desc' do
    def articles; find(:all, :conditions => "responsible_type = 'Article'"); end
    def comments; find(:all, :conditions => "responsible_type = 'Comment'"); end
    def entries; find(:all, :conditions => "repsonsible_type = 'Entry'"); end
    def projects; find(:all, :conditions => "responsible_type = 'Project'"); end
    def pictures; find(:all, :conditions => "responsible_type = 'Picture'"); end
    def groups; find(:all, :conditions => "responsible_type = 'Group'"); end
  end
  
  validates_presence_of     :email, :first_name, :last_name, :nick
  validates_presence_of     :password_hash, :password_salt unless RAILS_ENV = 'test'
  validates_uniqueness_of   :nick, :email
  validates_format_of       :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :on => :save
  
  attr_protected :password_salt, :password_hash
  
  def wheel?
    # Hardcoding this as well as preventing wheel password-changing because SQL values are too
    # easily modified. TODO: For more security the wheel list should be in a file with restrictive
    # write privileges.
    ['colin'].include?(self.nick)
  end
  
  def editable_by?(user)
    user.wheel? || self == user
  end
  
  def wants_notifications_for?(*args)
    false # TODO: stubbed :event_share
  end
    
  def to_param; self.nick; end #test
  
  def to_s; "#{self.full_name} (#{self.nick})"; end
  
  def full_name #test
    self.first_name +
    (self.middle_initial ? "#{self.middle_initial}." : " ") +
    self.last_name
  end
  
  def email_address #test
    "#{self.full_name} <#{self.email}>"
  end
  
  def layout
    self[:layout] || 'user_default'
  end
  
  def skin # FIXME: setup remote web server to hold custom skins
    self[:skin] ? "#{RAILS_ROOT}/blah/blah/#{self[:skin]}" : 'default.css'
  end
  
  def found(attrs={})
    grp = self.owned_groups.new(attrs)
    raise LimitError, "You (#{self.internal_name}) have reached the maximum number of groups you can found (#{APP[:limits][:groups]}). Please contact #{APP[:contact]} to resolve this issue." if self.owned_groups.count >= APP[:limits][:groups]
    if grp.save
      grp.join(self, :rank => Membership::RANKS[:founder])
    else
      return false
    end
    grp
  rescue LimitError => e
    grp.errors.add_to_base(e.message)
    return false
  end
  
  def password=(pass)
    raise AbuseError, "You are not permitted to modify THAT user." if self.wheel?
    salt = [Array.new(6){rand(256).chr}.join].pack('m').chomp
    self.password_salt, self.password_hash = salt, Digest::SHA256.hexdigest(pass + salt)
    return self
  end

  def self.authenticate(nick, password)
    user = User.find(:first, :conditions => ['nick = ?', nick])
    if user.blank? || Digest::SHA256.hexdigest(password + user.password_salt) != user.password_hash
      return false
    end
    user
  end
  
end
