class GetRidOfPermissionModelAndAddColumnsToAccessible < ActiveRecord::Migration
  def self.up
    add_column :users, :permission_rule_id, :integer, :default => DB[:public_rule]
    add_column :blogs, :permission_rule_id, :integer, :default => DB[:public_rule]
    add_column :articles, :permission_rule_id, :integer, :default => DB[:public_rule]
    add_column :pictures, :permission_rule_id, :integer, :default => DB[:public_rule]
    add_column :comments, :permission_rule_id, :integer, :default => DB[:public_rule]
    add_column :events, :permission_rule_id, :integer, :default => DB[:public_rule]
    add_column :galleries, :permission_rule_id, :integer, :default => DB[:public_rule]
    add_column :groups, :permission_rule_id, :integer, :default => DB[:public_rule]
    add_column :projects, :permission_rule_id, :integer, :default => DB[:public_rule]
    add_column :songs, :permission_rule_id, :integer, :default => DB[:public_rule]
    drop_table :permissions
  end

  def self.down
    create_table "permissions", :force => true do |t|
      t.string   "permissible_type"
      t.integer  "permission_rule_id"
      t.integer  "permissible_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    remove_column :songs, :permission_rule_id
    remove_column :projects, :permission_rule_id
    remove_column :groups, :permission_rule_id
    remove_column :galleries, :permission_rule_id
    remove_column :events, :permission_rule_id
    remove_column :comments, :permission_rule_id
    remove_column :pictures, :permission_rule_id
    remove_column :articles, :permission_rule_id
    remove_column :blogs, :permission_rule_id
    remove_column :users, :permission_rule_id
  end
end
