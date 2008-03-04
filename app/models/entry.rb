class Entry < ActiveRecord::Base
  include PluginPackage

  belongs_to :user
  belongs_to :event
  # For cases where a picture taken on phone is attached to an entry...
  has_one :picture, :as => :depictable
  
end
