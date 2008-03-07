class Entry < ActiveRecord::Base
  include PluginPackage

  belongs_to :user
  belongs_to :event
  # For cases where a picture taken on phone is attached to an entry...
  has_one :picture, :as => :depictable
  
  validates_presence_of :user_id
  validates_presence_of :content, :if => :location_empty?
  validates_presence_of :location, :if => :content_empty?
  
  def location_empty?; self.location.blank?; end
  def content_empty?; self.content.blank?; end
  
end
