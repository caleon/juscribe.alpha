class CreatePartials < ActiveRecord::Migration
  def self.up
    create_table :partials do |t|
      t.text :content
      t.integer :position
      t.references :article
      t.timestamps
    end
  end

  def self.down
    drop_table :partials
  end
end
