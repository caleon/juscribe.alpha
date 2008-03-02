class AddPrivateTogglerOnPermissionRules < ActiveRecord::Migration
  def self.up
    add_column :permission_rules, :private, :boolean, :default => false
  end

  def self.down
    remove_column :permission_rules, :private
  end
end
