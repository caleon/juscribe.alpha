class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.references :recipient, :sender
      t.string :subject
      t.text :body
      t.boolean :sent, :default => false
      t.boolean :read, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
