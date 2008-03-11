class Project < ActiveRecord::Base
  acts_as_itemizable :scope => :portfolio
  include PluginPackage
  
  validates_presence_of :name, :user_id
  validates_with_regexp :name
  belongs_to :user
  
end
