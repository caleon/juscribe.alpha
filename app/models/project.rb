class Project < ActiveRecord::Base
  acts_as_itemizable :portfolio
  include PluginPackage
  
  belongs_to :user
  
end
