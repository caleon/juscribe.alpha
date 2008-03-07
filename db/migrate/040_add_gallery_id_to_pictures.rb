class AddGalleryIdToPictures < ActiveRecord::Migration
  def self.up
    add_column :pictures, :list_id, :integer
  end

  def self.down
    remove_column :pictures, :list_id
  end
end
