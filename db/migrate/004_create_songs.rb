class CreateSongs < ActiveRecord::Migration
  def self.up
    create_table :songs do |t|
      t.string :title,
               :artist,
               :featuring,
               :genre,
               :miscellany
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :songs
  end
end
