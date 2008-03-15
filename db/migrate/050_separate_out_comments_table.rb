class SeparateOutCommentsTable < ActiveRecord::Migration
  def self.up    
    create_table :comments do |t|
      t.references :user, :original
      t.string :commentable_type
      t.integer :commentable_id
      t.text :body
      t.timestamps
    end
    drop_table :responses
  end

  def self.down
    create_table :responses do |t|
      t.references :user, :responsible, :secondary
      t.string :type, :responsible_type
      t.integer :number, :default => 0
      t.integer :variation
      t.text :body
      t.timestamps
    end
    drop_table :comments
  end
end
