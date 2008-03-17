class AddUserIdColumnToBlogsAsCreatorReference < ActiveRecord::Migration
  def self.up
    add_column :blogs, :user_id, :integer
  end

  def self.down
    remove_column :blogs, :user_id
  end
end
