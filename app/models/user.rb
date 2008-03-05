require 'digest/sha2'
require 'user_associations'
require 'user_validations'

class User < ActiveRecord::Base
  include Friendship
  include PluginPackage
  
  #set_primary_key "nick"
  
  after_validation {|user| @password, user.password_confirmation = nil, nil}
  attr_protected :nick, :email, :password_salt, :password_hash
    
  def wheel?
    # TODO: For more security the wheel list should be in a file with restrictive
    # write privileges.
    ['colin'].include?(self.nick)
  end
  
  def editable_by?(user)
    user.wheel? || self == user
  end
  
  def wants_notifications_for?(*args)
    false # TODO: stubbed :event_share
  end
  
  #def id; self.nick; end
  # This is done as last resort for activeresource to properly generate urls
  # But this makes things nasty and i woudl rather not make this change.
  # TODO: Find the code that calls #id on the record from within
  # ActionController::Base or ::Routing
    
  def to_param; self.nick; end #test
  
  def to_s; self.nick; end
  
  def name_and_nick
    self.full_name + "(#{self.nick})"
  end
  
  def full_name #test
    self.first_name.to_s +
    (self.middle_initial ? "#{self.middle_initial}." : " ") +
    self.last_name.to_s
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
  
  def password; @password; end
    
  def password=(pass)
    raise AbuseError, "You are not permitted to modify THAT user." if self.wheel?
    salt = [Array.new(6){rand(256).chr}.join].pack('m').chomp
    @old_password_hash = self.password_hash
    self.password_salt, self.password_hash = salt, Digest::SHA256.hexdigest(pass + salt)
    @password = pass
    return self
  end
  
  def password_changed?
    self.new_record? || (self.instance_variable_get(:@old_password_hash) != self.password_hash)
  end

  def self.authenticate(nick, password)
    user = User.find(:first, :conditions => ['nick = ?', nick])
    if user.blank? || Digest::SHA256.hexdigest(password + user.password_salt) != user.password_hash
      return false
    end
    user
  end
  
  def authenticate(password)
    if Digest::SHA256.hexdigest(password + self.password_salt) != self.password_hash
      self.errors.add(:password, "is incorrect.")
      return false
    end
    return true
  end
  
end
