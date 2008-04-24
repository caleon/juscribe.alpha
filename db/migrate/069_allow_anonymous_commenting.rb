class AllowAnonymousCommenting < ActiveRecord::Migration
  def self.up
    add_column :comments, :email, :string
    add_column :comments, :nick, :string
    add_column :comments, :ip_addr, :string
  end

  def self.down
    remove_column :comments, :ip_addr
    remove_column :comments, :nick
    remove_column :comments, :email
  end
end
