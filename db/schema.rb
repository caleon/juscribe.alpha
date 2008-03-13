# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 48) do

  create_table "articles", :force => true do |t|
    t.string   "title"
    t.string   "permalink"
    t.text     "content"
    t.integer  "comments_count"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "published_date"
    t.time     "published_time"
  end

  create_table "entries", :force => true do |t|
    t.string   "content"
    t.string   "location"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
  end

  create_table "events", :force => true do |t|
    t.string   "name"
    t.string   "location"
    t.string   "content"
    t.datetime "begins_at"
    t.datetime "ends_at"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.integer  "user_id"
    t.integer  "list_id"
    t.string   "type"
    t.string   "name"
    t.text     "content"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uri"
  end

  create_table "lists", :force => true do |t|
    t.integer  "user_id"
    t.string   "type"
    t.string   "name"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "style"
  end

  create_table "memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.string   "title"
    t.integer  "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.integer  "recipient_id"
    t.integer  "sender_id"
    t.string   "subject"
    t.text     "body"
    t.boolean  "read",         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "partials", :force => true do |t|
    t.text     "content"
    t.integer  "position"
    t.integer  "article_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permission_rules", :force => true do |t|
    t.string   "name"
    t.text     "allowed"
    t.text     "denied"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "private",     :default => false
  end

  create_table "permissions", :force => true do |t|
    t.string   "permissible_type"
    t.integer  "permission_rule_id"
    t.integer  "permissible_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pictures", :force => true do |t|
    t.string   "name"
    t.text     "caption"
    t.integer  "depictable_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "depictable_type"
    t.integer  "position"
    t.integer  "list_id"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.text     "skillset"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "list_id"
    t.integer  "position"
  end

  create_table "responses", :force => true do |t|
    t.integer  "user_id"
    t.integer  "responsible_id"
    t.integer  "secondary_id"
    t.string   "type"
    t.string   "responsible_type"
    t.integer  "number",           :default => 0
    t.integer  "variation"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "songs", :force => true do |t|
    t.string   "title"
    t.string   "artist"
    t.string   "featuring"
    t.string   "genre"
    t.string   "miscellany"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "list_id"
    t.integer  "position"
  end

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

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "middle_initial"
    t.string   "last_name"
    t.string   "nick"
    t.string   "email"
    t.string   "password_salt"
    t.string   "password_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "friend_ids"
    t.string   "layout"
    t.string   "skin"
    t.date     "birthdate"
    t.integer  "sex"
    t.string   "type"
    t.boolean  "admin",          :default => false
  end

  create_table "widgets", :force => true do |t|
    t.integer  "user_id"
    t.integer  "widgetable_id"
    t.string   "type"
    t.string   "widgetable_type"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

end
