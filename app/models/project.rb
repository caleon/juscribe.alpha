class Project < ActiveRecord::Base
  acts_as_itemizable :portfolio
  include PluginPackage
  
  validates_presence_of :name, :user_id
  belongs_to :user
  
end
