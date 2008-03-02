class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :title,
               :type,
               :permalink
      t.text :content
      t.boolean :private
      t.integer :comments_count
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
