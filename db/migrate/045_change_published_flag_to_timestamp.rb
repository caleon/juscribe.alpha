class ChangePublishedFlagToTimestamp < ActiveRecord::Migration
  def self.up
    remove_column :articles, :published
    add_column :articles, :published_at, :datetime
  end

  def self.down
    remove_column :articles, :published_at
    add_column :articles, :published, :boolean, :default => false
  end
end
