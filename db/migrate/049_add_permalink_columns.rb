class AddPermalinkColumns < ActiveRecord::Migration
  def self.up
    add_column :songs, :permalink, :string
    add_column :lists, :permalink, :string
  end

  def self.down
    remove_column :lists, :permalink
    remove_column :songs, :permalink
  end
end
