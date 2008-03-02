class AddEventEntryAssociation < ActiveRecord::Migration
  def self.up
    add_column :entries, :event_id, :integer
  end

  def self.down
    remove_column :entries, :event_id
  end
end
