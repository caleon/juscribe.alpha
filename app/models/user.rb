require 'digest/sha2'
require 'user/friendship'
require 'user/user_associations'
require 'user/user_validations'

class User < ActiveRecord::Base
  include Friendship
  include_custom_plugins  
  
  # TODO: acts_as_cached
    
  attr_protected :nick, :email, :password_salt, :password_hash, :type
  attr_accessor :tos_agreement
  # For Widget
  alias_attribute :name, :nick
  alias_attribute :content, :full_name
  
  def display_name; self.nick; end
  
  def self.primary_find(*args)
    find_by_nick(*args)
  end
  
  def users; self; end
    
  def wheel?
    self.id == DB[:wheel_id]
  end
  
  def admin?
    self.wheel? || self[:admin]
  end
  
  def editable_by?(user)
    (user && user.admin?) || self == user
  end
  
  def wants_notifications_for?(arg)
    self[:notify] ||= {}
    self[:notify][arg].nil? ? true : self[:notify][arg] # TODO: stubbed :event_share
  end
  
  def set_notification_for(arg, bool=nil)
    self[:notify] ||= {}
    self[:notify][arg] = bool
  end
    
  def to_param; self.nick; end
  
  def to_s; self.nick; end
  
  def to_path(for_associated=false)
    { :"#{for_associated ? 'user_id' : 'id'}" => self.to_param }
  end
  
  def path_name_prefix; "user"; end
  
  def name_and_nick
    self.full_name + " (#{self.nick})"
  end
  
  def full_name #test
    self.first_name.to_s + " " +
    (self.middle_initial ? "#{self.middle_initial}. " : " ") +
    self.last_name.to_s
  end
  
  def email_address #test
    "#{self.full_name} <#{self.email}>"
  end
  
  def age
    today, bday = Date.today, self.birthdate
    years = today.year - bday.year
    years -= 1 if (bday + years.years) > today
    years
  end
  
  def sex(full=false)
    return nil unless self[:sex]
    sym = [:f, :m][self[:sex]]
    full ? { :f => 'female', :m => 'male' }[sym] : sym.to_s
  end
  
  def found(attrs={}, opts={})
    grp = self.owned_groups.new(attrs)
    raise LimitError, "You (#{self.internal_name}) have reached the maximum number of groups you can found (#{APP[:limits][:groups]}). Please contact #{APP[:contact]} to resolve this issue." if self.owned_groups.count >= APP[:limits][:groups]
    unless opts[:without_save] || false
      if grp.save
        grp.join(self, :rank => Membership::RANKS[:founder])
      else
        return false
      end
    end
    grp
  rescue LimitError => e
    grp.errors.add_to_base(e.message)
    return false
  end
  
  def create_rule(attrs={})
    attrs[:user_id] = self.id
    raise ArgumentError, 'Need to supply a user or user_id.' unless attrs[:user_id]
    self.rule = PermissionRule.create!(attrs)          
  end
  
  def email=(addy)
    @old_email = self.email
    self[:email] = addy
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
  
  def accessible_by?(user=nil)
    self == user || self.rule.accessible_by?(user)
  end

  def self.authenticate(nick, pass)
    user = User.find(:first, :conditions => ['nick = ?', nick])
    if user.blank? || Digest::SHA256.hexdigest(pass + user.password_salt) != user.password_hash
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
  
  private
  def self.generate_password_salt_and_hash_for(pass)
    salt = [Array.new(6){rand(256).chr}.join].pack('m').chomp
    [salt, Digest::SHA256.hexdigest(pass + salt)]
  end
  
end
