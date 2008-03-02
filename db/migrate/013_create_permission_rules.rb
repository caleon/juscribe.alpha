class CreatePermissionRules < ActiveRecord::Migration
  def self.up
    create_table :permission_rules do |t|
      t.string :name
      t.text :allow, :deny, :description
      t.timestamps
    end
  end

  def self.down
    drop_table :permission_rules
  end
end
