class AddOptionsToPermissionRules < ActiveRecord::Migration
  def self.up
    add_column :permission_rules, :options, :text
  end

  def self.down
    remove_column :permission_rules, :options
  end
end
