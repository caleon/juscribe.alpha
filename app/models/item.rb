class Item < ActiveRecord::Base
  acts_as_itemizable
  include PluginPackage

  belongs_to :user
  
  validates_presence_of :user_id, :list_id
  validates_format_of :name, :with => /^[^\s].+[^\s]$/i
  
  def name; self[:name] || "Untitled Item"; end
  
end
