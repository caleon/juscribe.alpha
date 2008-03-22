class BunchaTableEdits < ActiveRecord::Migration
  def self.up
    add_column :groups, :permalink, :string
    add_column :users, :about, :text
    add_column :pictures, :source, :string
  end

  def self.down
    remove_column :pictures, :source
    remove_column :users, :about
    remove_column :groups, :permalink
  end
end
