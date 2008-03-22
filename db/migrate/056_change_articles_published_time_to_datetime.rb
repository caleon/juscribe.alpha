class ChangeArticlesPublishedTimeToDatetime < ActiveRecord::Migration
  def self.up
    change_column :articles, :published_time, :datetime
  end

  def self.down
    change_column :articles, :published_time, :time
  end
end
