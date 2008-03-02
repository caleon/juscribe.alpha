class ProjectIsAnItemOfPortfolioList < ActiveRecord::Migration
  def self.up
    add_column :projects, :list_id, :integer
    add_column :projects, :position, :integer
  end

  def self.down
    remove_column :projects, :position
    remove_column :projects, :list_id
  end
end
