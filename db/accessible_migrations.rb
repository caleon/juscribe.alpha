class AccessibleMigrations < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.string :permissible_type
      t.references :permission_rule, :permissible
      t.timestamps
    end
    create_table :permission_rules do |t|
      t.string :name
      t.text :allow, :deny, :description
			t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :permission_rules
    drop_table :permissions
  end
end
