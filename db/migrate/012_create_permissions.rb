class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.string :permissible_type
      t.references :permission_rule, :permissible
      t.timestamps
    end
  end

  def self.down
    drop_table :permissions
  end
end
