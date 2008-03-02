class Entry < ActiveRecord::Base
  acts_as_taggable
  acts_as_accessible
  acts_as_responsible
  acts_as_widgetable
  
  belongs_to :user
  belongs_to :event
  # For cases where a picture taken on phone is attached to an entry...
  has_one :picture, :as => :depictable
  
end
