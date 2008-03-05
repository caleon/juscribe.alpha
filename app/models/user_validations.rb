class User < ActiveRecord::Base
  validates_presence_of     :email, :first_name, :last_name, :nick
  validates_uniqueness_of   :nick, :email
  validates_format_of       :email, :on => :save,
                            :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
                            
  validates_presence_of     :password, :if => :password_changed? unless RAILS_ENV == 'test'
  validates_confirmation_of :password, :if => :password_changed?
  validates_presence_of     :password_confirmation, :if => :password_changed?
  validates_presence_of     :password_hash, :password_salt unless RAILS_ENV == 'test'

  
  def password_changed?
    orig_pw_hash = self.instance_variable_get(:@old_password_hash)
    self.new_record? || (!orig_pw_hash.nil? && orig_pw_hash != self.password_hash)
  end
end