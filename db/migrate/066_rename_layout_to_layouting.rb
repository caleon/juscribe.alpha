class RenameLayoutToLayouting < ActiveRecord::Migration
  def self.up
    rename_table :layouts, :layoutings
  end

  def self.down
    rename_table :layoutings, :layouts
  end
end
