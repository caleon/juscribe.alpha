class CreateBlogs < ActiveRecord::Migration
  def self.up
    create_table :blogs do |t|
      t.string :bloggable_type
      t.integer :bloggable_id
      t.string :name, :permalink
      t.text :description
      t.timestamps
    end
    add_column :articles, :blog_id, :integer
    add_column :articles, :clips_count, :integer, :default => 0
  end

  def self.down
    remove_column :articles, :clips_count
    remove_column :articles, :blog_id
    drop_table :blogs
  end
end
