class AddLedeTagToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :lede_tag, :string
    add_column :blogs, :lede_tag, :string
    add_column :blogs, :premium_since, :datetime
  end

  def self.down
    remove_column :blogs, :premium_since
    remove_column :blogs, :lede_tag
    remove_column :articles, :lede_tag
  end
end
