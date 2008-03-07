class Song < ActiveRecord::Base
  acts_as_itemizable :gallery
  include PluginPackage

  belongs_to :user
  
  validates_presence_of :title, :artist, :user_id
  
  # something like 'widget_alias :name, :title' can handle the following mapping.
  def name; self.title; end
  def name=(str); self.title = str; end
  
end
