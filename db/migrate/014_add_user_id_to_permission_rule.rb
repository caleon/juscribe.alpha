class AddUserIdToPermissionRule < ActiveRecord::Migration
  def self.up
    add_column :permission_rules, :user_id, :integer
  end

  def self.down
    remove_column :permission_rules, :user_id
  end
end
