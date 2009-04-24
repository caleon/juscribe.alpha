class AddNotifyToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :notify, :boolean
  end

  def self.down
    remove_column :comments, :notify
  end
end
