class AddNotificationsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :notifications, :text
  end

  def self.down
    remove_column :users, :notifications
  end
end
