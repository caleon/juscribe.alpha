class ChangeReadBooleanToReadAtTimestamp < ActiveRecord::Migration
  def self.up
    remove_column :messages, :read
    add_column :messages, :read_at, :datetime
  end

  def self.down
    remove_column :messages, :read_at
    add_column :messages, :read, :boolean
  end
end
