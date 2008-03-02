class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.references :user, :group
      t.string :title
      t.integer :rank
      t.timestamps
    end
  end

  def self.down
    drop_table :memberships
  end
end
