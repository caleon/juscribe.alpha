class AddBirthdayColumn < ActiveRecord::Migration
  def self.up
    add_column :users, :birthdate, :date
  end

  def self.down
    remove_column :users, :birthdate
  end
end
