class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.string :content,
               :location
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :entries
  end
end
