class RemoveCommentsTable < ActiveRecord::Migration
  def self.up
    drop_table :comments
  end

  def self.down
    create_table :comments do |t|
      t.string :commentable_type,
               :title,
               :name,
               :email,
               :ip_addr
      t.text :content
      t.references :user
      t.timestamps
    end
  end
end
