class AddParentIdToPicturesForThumbnails < ActiveRecord::Migration
  def self.up
    add_column :pictures, :parent_id, :integer
  end

  def self.down
    remove_column :pictures, :parent_id
  end
end
