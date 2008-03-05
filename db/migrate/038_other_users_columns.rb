class OtherUsersColumns < ActiveRecord::Migration
  def self.up
    add_column :users, :sex, :integer
    add_column :users, :type, :string
  end

  def self.down
    remove_column :users, :type
    remove_column :users, :sex
  end
end
