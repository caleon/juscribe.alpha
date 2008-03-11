# Submodels are included via the environment.rb file's config.load_paths.
class List < ActiveRecord::Base      
  set_itemizables
  include PluginPackage

  belongs_to :user
  
  validates_presence_of :user_id
  validates_associated :items
  validates_with_regexp :name
  
  STYLES = %w( cardinal ordinal roman numerical dashed dotted )
  
  def name; self[:name] || "Untitled List"; end
  
end
