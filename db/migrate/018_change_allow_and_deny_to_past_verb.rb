class ChangeAllowAndDenyToPastVerb < ActiveRecord::Migration
  def self.up
    rename_column :permission_rules, :allow, :allowed
    rename_column :permission_rules, :deny, :denied
  end

  def self.down
    rename_column :permission_rules, :denied, :deny
    rename_column :permission_rules, :allowed, :allow
  end
end
