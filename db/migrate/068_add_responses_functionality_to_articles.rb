class AddResponsesFunctionalityToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :original_id, :integer
  end

  def self.down
    remove_column :articles, :original_id
  end
end
