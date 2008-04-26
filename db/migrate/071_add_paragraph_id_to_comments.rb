class AddParagraphIdToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :paragraph_hash, :string
  end

  def self.down
    remove_column :comments, :paragraph_hash
  end
end
