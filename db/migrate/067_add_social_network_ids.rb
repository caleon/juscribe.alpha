class AddSocialNetworkIds < ActiveRecord::Migration
  def self.up
    add_column :users, :social_networks, :text
  end

  def self.down
    remove_column :users, :social_networks
  end
end
