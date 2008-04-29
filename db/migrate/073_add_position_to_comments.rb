class AddPositionToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :position, :integer
  end

  def self.down
    remove_column :comments, :position
  end
end
