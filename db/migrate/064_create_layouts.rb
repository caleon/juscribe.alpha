class CreateLayouts < ActiveRecord::Migration
  def self.up
    create_table :layouts do |t|
      t.references :user, :layoutable
      t.string :layoutable_type, :skin, :name
      t.text :layout_blob
      t.timestamps
    end
  end

  def self.down
    drop_table :layouts
  end
end
