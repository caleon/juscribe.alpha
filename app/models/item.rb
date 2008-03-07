class Item < ActiveRecord::Base
  acts_as_itemizable
  include PluginPackage

  belongs_to :user
  
end
