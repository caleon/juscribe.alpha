class RenameEntryToThoughtlet < ActiveRecord::Migration
  def self.up
    rename_table :entries, :thoughtlets
  end

  def self.down
    rename_table :thoughtlets, :entries
  end
end
