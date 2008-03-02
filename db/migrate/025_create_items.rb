class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.references :user, :list
      t.string :type, :title
      t.text :content
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
