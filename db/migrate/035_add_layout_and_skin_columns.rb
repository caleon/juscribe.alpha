class AddLayoutAndSkinColumns < ActiveRecord::Migration
  def self.up
    add_column :users, :layout, :string
    add_column :users, :skin, :string
  end

  def self.down
    remove_column :users, :skin
    remove_column :users, :layout
  end
end
