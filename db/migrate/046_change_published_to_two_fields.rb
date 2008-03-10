class ChangePublishedToTwoFields < ActiveRecord::Migration
  def self.up
    change_column :articles, :published_at, :date
    rename_column :articles, :published_at, :published_date
    add_column :articles, :published_time, :time
  end

  def self.down
    remove_column :articles, :published_time, :time
    rename_column :articles, :published_date, :published_at
    change_column :articles, :published_at, :datetime
  end
end
