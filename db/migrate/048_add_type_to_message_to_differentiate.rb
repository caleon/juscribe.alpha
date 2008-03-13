class AddTypeToMessageToDifferentiate < ActiveRecord::Migration
  def self.up
    remove_column :messages, :sent
  end

  def self.down
    add_column :messages, :sent, :boolean
  end
end
