class Gallery < ActiveRecord::Base
  include_custom_plugins
  
  belongs_to :user, :inherits_layout => true
  has_many :pictures, :as => :depictable, :order => :position
  has_one :primary_picture, :class_name => 'Picture', :as => :depictable, :order => :position
  
  validates_presence_of :user_id
  validates_with_regexp :name
  
  alias_attribute :content, :description
  
  def name
    self[:name] || "Untitled"
  end
  
  def to_path(for_associated=false)
    if self.user.nil?
      { :"#{for_associated ? 'gallery_id' : 'id'}" => self.to_param }
    else
      { :user_id => self.user.to_param, :"#{for_associated ? 'gallery_id' : 'id'}" => self.to_param }
    end
  end
  
  def path_name_prefix
    [ self.user.path_name_prefix, 'gallery' ].join('_')
  end
  
end