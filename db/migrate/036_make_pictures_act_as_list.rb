class MakePicturesActAsList < ActiveRecord::Migration
  def self.up
    add_column :pictures, :depictable_type, :string
    add_column :pictures, :position, :integer
  end

  def self.down
    remove_column :pictures, :position
    remove_column :pictures, :depictable_type
  end
end
