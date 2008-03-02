class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :first_name,
               :middle_initial,
               :last_name,
               :login,
               :email,
               :password_salt,
               :password_hash
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
