class Project < ActiveRecord::Base
  acts_as_itemizable :scope => :portfolio
  include_custom_plugins  
  belongs_to :user
  
  validates_presence_of :name, :user_id
  validates_with_regexp :name
  
  alias_attribute :content, :description
  
  def to_path
    { :user_id => self.user.to_param, :id => self.to_param }
  end
    
end
