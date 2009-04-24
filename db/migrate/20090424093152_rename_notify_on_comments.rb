class RenameNotifyOnComments < ActiveRecord::Migration
  def self.up
    rename_column :comments, :notify, :wants_notifications
  end

  def self.down
    rename_column :comments, :wants_notifications, :notify
  end
end
