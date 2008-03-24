class RemoveClipsCountColumn < ActiveRecord::Migration
  def self.up
    remove_column :articles, :clips_count
  end

  def self.down
    add_column :articles, :clips_count, :integer, :default => 0
  end
end
