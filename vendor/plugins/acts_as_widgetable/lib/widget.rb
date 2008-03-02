class Widget < ActiveRecord::Base
  # This can be subclassed with column `type`
  belongs_to :user
  belongs_to :widgetable, :polymorphic => true
  acts_as_list :scope => :user_id
  
  validates_uniqueness_of :widgetable_id, :scope => [:user_id, :widgetable_type]
  
  # Widgetable things include models like Article, Comment, Event, etc.
  # Widgets are basically box elements that show up on a user's page.
  # A user can widget an article written by someone else.
  
  def full_name
    "#{self.name}: #{self.widgetable.name}"
  end
  
  def placed?; self.position?; end

  def place!(pos=nil, without_save=false)
    if other_wid = Widget.find(:first, :conditions => ["user_id = ? AND position = ?", self.user_id, pos])
      other_wid.unplace!
    end
    without_save ? self.position = pos : self.update_attribute(:position, pos)
  end
  
  def place(pos)
    self.place!(pos, true)
  end
  
  def unplace!(pos)
    self.update_attribute(:position, nil)
  end
  
end

