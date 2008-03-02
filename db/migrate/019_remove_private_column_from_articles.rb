class RemovePrivateColumnFromArticles < ActiveRecord::Migration
  def self.up
    remove_column :articles, :private
  end

  def self.down
    add_column :articles, :private, :boolean
  end
end
