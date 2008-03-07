class Song < ActiveRecord::Base
  acts_as_itemizable :gallery
  include PluginPackage

  belongs_to :user
  
  #alias :name :title
  #alias :name= :title=
  #widget_alias :name, :title
  
end
