class AddImportedAtToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :imported_at, :datetime
  end

  def self.down
    remove_column :articles, :imported_at
  end
end
