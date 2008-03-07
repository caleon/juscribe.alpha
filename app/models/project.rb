class Project < ActiveRecord::Base
  acts_as_itemizable :portfolio
  include PluginPackage
  
  validates_presence_of :name, :user_id
  validates_format_of :name, :with => /^[^\s].+[^\s]$/i
  belongs_to :user
  
end
