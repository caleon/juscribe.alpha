class MorePermissionRuleIdColumns < ActiveRecord::Migration
  def self.up
    add_column :thoughtlets, :permission_rule_id, :integer, :default => DB[:public_rule]
    add_column :widgets, :permission_rule_id, :integer, :default => DB[:public_rule]
  end

  def self.down
    remove_column :widgets, :permission_rule_id
    remove_column :thoughtlets, :permission_rule_id
  end
end
