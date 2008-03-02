class CreateLists < ActiveRecord::Migration
  def self.up
    create_table :lists do |t|
      t.references :user
      t.string :type, :title
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :lists
  end
end
