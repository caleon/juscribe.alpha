class AddPositionToSongs < ActiveRecord::Migration
  def self.up
    add_column :songs, :position, :integer
  end

  def self.down
    add_column :songs, :position
  end
end
