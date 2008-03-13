class RemoveTypeColumnFromArticles < ActiveRecord::Migration
  def self.up
    remove_column :articles, :type
  end

  def self.down
    add_column :articles, :type, :string
  end
end
