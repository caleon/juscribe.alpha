class Gallery < ActiveRecord::Base
  include_custom_plugins
  
  belongs_to :user
  has_many :pictures, :as => :depictable, :order => :position
  has_one :primary_picture, :class_name => 'Picture', :as => :depictable, :order => :position
  
  validates_presence_of :user_id
  validates_with_regexp :name
  
  alias_attribute :content, :description
  
  def name
    self[:name] || "Untitled"
  end
  
end