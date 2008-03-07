class TaggableMigrations < ActiveRecord::Migration
  def self.up
    create_table "taggings", :force => true do |t|
      t.string   "taggable_type"
      t.integer  "taggable_id"
      t.integer  "user_id"
      t.integer  "tag_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "tags", :force => true do |t|
      t.string   "name"
      t.string   "kind"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
  
  def self.down
    drop_table :tags
    drop_table :taggings
  end
end