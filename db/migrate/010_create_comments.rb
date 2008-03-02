class CreateComments < ActiveRecord::Migration
  def self.up
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

  def self.down
    drop_table :comments
  end
end
