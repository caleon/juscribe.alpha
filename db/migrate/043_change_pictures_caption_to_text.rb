class ChangePicturesCaptionToText < ActiveRecord::Migration
  def self.up
    change_column :pictures, :caption, :text
  end

  def self.down
    change_column :pictures, :caption, :string
  end
end
