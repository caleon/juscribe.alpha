class WtfWhyIsEventsContentString < ActiveRecord::Migration
  def self.up
    change_column :events, :content, :text
  end

  def self.down
    change_column :events, :content, :string
  end
end
