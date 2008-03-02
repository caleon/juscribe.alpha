class CreateTaggings < ActiveRecord::Migration
  def self.up
    create_table :taggings do |t|
      t.string :taggable_type
      t.references :taggable, :user, :tag
      t.timestamps
    end
  end

  def self.down
    drop_table :taggings
  end
end
