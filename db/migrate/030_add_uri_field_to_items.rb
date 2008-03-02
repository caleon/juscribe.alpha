class AddUriFieldToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :uri, :string
  end

  def self.down
    remove_column :items, :uri
  end
end
