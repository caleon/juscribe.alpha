class ResponsibleMigrations < ActiveRecord::Migration
  def self.up
    create_table :responses do |t|
      t.references :user, :responsible, :secondary
      t.string :type, :responsible_type
      t.integer :number, :default => 0
      t.integer :variation
      t.text :body
      t.timestamps
    end
  end

  def self.down
    drop_table :responses
  end
end


# This uses one table and several subclasses of the main class Response, differentiated by `type`.