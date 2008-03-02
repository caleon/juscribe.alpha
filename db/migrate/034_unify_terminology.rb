class UnifyTerminology < ActiveRecord::Migration
  def self.up
    rename_column :events, :starts_at, :begins_at
    rename_column :events, :title, :name
    rename_column :items, :title, :name
    rename_column :lists, :title, :name
    rename_column :pictures, :title, :name
    rename_column :projects, :title, :name
    rename_column :widgets, :title, :name
  end

  def self.down
    rename_column :widgets, :name, :title
    rename_column :projects, :name, :title
    rename_column :pictures, :name, :title
    rename_column :lists, :name, :title
    rename_column :items, :name, :title
    rename_column :events, :name, :title
    rename_column :events, :begins_at, :starts_at
  end
end
