class KeepTrackOfCommentRepliesCount < ActiveRecord::Migration
  def self.up
    add_column :comments, :replies_count, :integer, :default => 0
  end

  def self.down
    remove_column :comments, :replies_count
  end
end
