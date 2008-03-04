require 'digest/sha2'
require 'user_associations'

class User < ActiveRecord::Base
  include Friendship
  include PluginPackage
  
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
