class RenameArticlesPublishedTimeToPublishedAt < ActiveRecord::Migration
  def self.up
    rename_column :articles, :published_time, :published_at
  end

  def self.down
    rename_column :articles, :published_at, :published_time
  end
end
