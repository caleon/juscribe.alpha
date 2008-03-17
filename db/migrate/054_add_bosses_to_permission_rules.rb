class AddBossesToPermissionRules < ActiveRecord::Migration
  def self.up
    add_column :permission_rules, :bosses, :text
  end

  def self.down
    remove_column :permission_rules, :bosses
  end
end
