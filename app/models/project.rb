class Project < ActiveRecord::Base
  acts_as_itemizable :scope => :portfolio
  include PluginPackage
  
  validates_presence_of :name, :user_id
  validates_with_regexp :name
  belongs_to :user
  
  def to_path
    { :user_id => self.user.to_param, :id => self.to_param }
  end
    
end
