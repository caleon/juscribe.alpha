class User < ActiveRecord::Base
  validates_presence_of     :email, :first_name, :last_name, :nick
  validates_presence_of     :password_hash, :password_salt unless RAILS_ENV = 'test'
  validates_uniqueness_of   :nick, :email
  validates_format_of       :email, :on => :save,
                            :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
end