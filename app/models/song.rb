class Song < ActiveRecord::Base
  acts_as_itemizable :playlist
  include PluginPackage

  belongs_to :user
  
  validates_presence_of :title, :artist, :user_id
  validates_format_of :title, :with => /^[^\s].+[^\s]$/i
  validates_format_of :artist, :with => /^[^\s].+[^\s]$/i
  
  # something like 'widget_alias :name, :title' can handle the following mapping.
  def name; self.title; end
  def name=(str); self.title = str; end
  
end
