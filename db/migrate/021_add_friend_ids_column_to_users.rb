class AddFriendIdsColumnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :friend_ids, :text
  end

  def self.down
    remove_column :users, :friend_ids
  end
end
