class Item < ActiveRecord::Base
  acts_as_taggable
  acts_as_accessible
  acts_as_responsible
  acts_as_widgetable
  
  belongs_to :user # This may not be necessary, but for collaborative lists, yes.
  has_one :picture, :as => :depictable
  belongs_to :list
  acts_as_list :scope => :list
  
  validates_uniqueness_of :id, :scope => :list_id
  
  def accessible_by?(user)
    self.list.nil? ? super : self.list.accessible_by?(user) && super
  end
  
end
