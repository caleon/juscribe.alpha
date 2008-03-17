class AddGalleriesTable < ActiveRecord::Migration
  def self.up
    create_table :galleries do |t|
      t.references :user
      t.string :name
      t.text :description
      t.timestamps
    end
    remove_column :pictures, :list_id
  end

  def self.down
    add_column :pictures, :list_id, :integer
    drop_table :galleries
  end
end
