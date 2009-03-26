class Thoughtlet < ActiveRecord::Base
  include_custom_plugins
  
  is_indexed :fields => [ 'content' ]  

  belongs_to :user, :inherits_layout => true
  belongs_to :event
  # For cases where a picture taken on phone is attached to a thoughtlet...
  has_one :picture, :as => :depictable
  
  validates_presence_of :user_id
  validates_presence_of :content, :if => :location_empty?
  validates_presence_of :location, :if => :content_empty?
  validates_with_regexp :content
  validates_with_regexp :location
  
  # For Widget
  def name; self.content[0..10]; end
  def to_s; self.name; end
  
  def to_path(for_associated=false)
    if self.user.nil?
      { :"#{for_associated ? 'thoughtlet_id' : 'id'}" => self.to_param }
    else
      { :user_id => self.user.to_param, :"#{for_associated ? 'thoughtlet_id' : 'id'}" => self.to_param }
    end
  end
  
  def path_name_prefix
    [ self.user.path_name_prefix, 'thoughtlet' ].join('_')
  end
  
  def location_empty?; self.location.blank?; end
  def content_empty?; self.content.blank?; end
  
end
