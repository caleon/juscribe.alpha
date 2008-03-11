class User < ActiveRecord::Base
  PROHIBITED_NICKS = %w(colin caleon admin superuser administrator user users show edit update create friend friends new root sysadmin system login logout mine mailbox any about unfriend befriend )
  
  validates_presence_of     :email, :first_name, :last_name, :nick, :birthdate
  validates_uniqueness_of   :nick, :email
  validates_exclusion_of    :nick, :in => PROHIBITED_NICKS, :on => :create
  validates_length_of       :nick, :in => 3..20
  validates_length_of       :first_name, :in => 2..30
  validates_length_of       :middle_initial, :in => 0..1, :allow_nil => true
  validates_length_of       :last_name, :in => 2..30

  validates_numericality_of :sex, :allow_nil => true
  validates_inclusion_of    :sex, :in => %w( m f ), :allow_nil => true
  validates_with_regexp     :nick, :first_name, :middle_initial, :last_name, :email
  
  validates_acceptance_of   :tos_agreement, :on => :create
  # worked with '1' as value. not true (of TrueClass)
  
  if RAILS_ENV != 'test'
    validates_presence_of     :password, :if => :password_changed?
    validates_length_of       :password, :in => 6..30, :if => :password_changed?
    validates_confirmation_of :password, :if => :password_changed?
    validates_presence_of     :password_confirmation, :if => :password_changed?
    validates_presence_of     :password_hash, :password_salt
  else
    attr_accessor :password_confirmation
  end

  after_validation {|user| @password, user.password_confirmation = nil, nil}
  before_save :deliver_pw_change_notification
  before_save :deliver_email_change_notification
  
  def password_changed?
    orig_pw_hash = self.instance_variable_get(:@old_password_hash)
    self.new_record? || (!orig_pw_hash.nil? && orig_pw_hash != self.password_hash)
  end
  
  def email_changed?
    orig_email = self.instance_variable_get(:@old_email)
    self.new_record? || (!orig_email.nil? && orig_email != self.email)
  end
  
  def deliver_pw_change_notification
    Notifier.deliver_password_change_notification(self) if self.password_changed?
  end
  
  def deliver_email_change_notification
    Notifier.deliver_email_change_notification(self) if self.email_changed?
  end
end