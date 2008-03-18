class Item < ActiveRecord::Base
  acts_as_itemizable
  include_custom_plugins  

  belongs_to :user
  
  validates_presence_of :user_id, :list_id
  validates_with_regexp :name
  
  def name; self[:name] || "Untitled Item"; end
  
  def path_name_prefix; 'item'; end
  
end
