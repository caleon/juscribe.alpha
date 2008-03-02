class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :title,
               :location,
               :content
      t.datetime :starts_at,
                 :ends_at
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
