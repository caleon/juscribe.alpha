class UseSerializableInsteadOfSecondaryId < ActiveRecord::Migration
  def self.up
    remove_column :comments, :original_id
    add_column :comments, :reference_ids, :text
  end

  def self.down
    remove_column :comments, :reference_ids
    add_column :comments, :original_id, :integer
  end
end
