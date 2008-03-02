class SubclassListsWithinArticle < ActiveRecord::Migration
  def self.up
    add_column :songs, :list_id, :integer
  end

  def self.down
    remove_column :songs, :list_id
  end
end
