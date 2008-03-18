class Entry < ActiveRecord::Base
  include_custom_plugins  

  belongs_to :user
  belongs_to :event
  # For cases where a picture taken on phone is attached to an entry...
  has_one :picture, :as => :depictable
  
  validates_presence_of :user_id
  validates_presence_of :content, :if => :location_empty?
  validates_presence_of :location, :if => :content_empty?
  validates_with_regexp :content
  validates_with_regexp :location
  
  # For Widget
  def name; self.content[0..10]; end
  def to_s; self.name; end
  
  def to_path
    if self.user.nil?
      { :id => self.to_param }
    else
      { :user_id => self.user.to_param, :id => self.to_param }
    end
  end
  
  def path_name_prefix
    [ self.user.path_prefix, 'entry' ].join('_')
  end
  
  def location_empty?; self.location.blank?; end
  def content_empty?; self.content.blank?; end
  
end
