class WidgetableMigrations < ActiveRecord::Migration
  def self.up
    create_table :widgets do |t|
      t.references :user, :widgetable
      t.string :type, :widgetable_type, :title
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :widgets
  end
end
