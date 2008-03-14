class Widget < ActiveRecord::Base
  # This can be subclassed with column `type`
  belongs_to :user
  belongs_to :widgetable, :polymorphic => true
  acts_as_list :scope => :user_id
  
  validates_uniqueness_of :widgetable_id, :scope => [:user_id, :widgetable_type]
  validates_presence_of :user_id, :widgetable_id, :widgetable_type
  
  # Widgetable things include models like Article, Comment, Event, etc.
  # Widgets are basically box elements that show up on a user's page.
  # A user can widget an article written by someone else.
  
  def to_path(for_associated=false)
    if self.user.nil?
      { :"#{for_associated ? 'clip_id' : 'id'}" => self.to_param }
    else
      { :user_id => self.user.to_param, :"#{for_associated ? 'clip_id' : 'id'}" => self.to_param }
    end
  end
  
  def to_polypath
    { :id => self.to_param }.merge(self.widgetable.nil? ? {} : self.widgetable.to_path(true))
  end
  
  def full_name
    (self[:name] ? "#{self[:name]}: " : "") + (self.widgetable.name rescue self.widgetable.title)
  end
  
  def wid_name
    self.widgetable.name rescue nil
  end
  
  def wid_content
    self.widgetable.content
  rescue
    self.widgetable.body rescue nil
  end
  
  def wid_user
    self.widgetable.user
  rescue
    self.widgetable.owner rescue nil # maybe also #creator
  end
  
  def wid_partial(base, kind=nil)
    base + '/' + self.widgetable_type.underscore + (kind ? "_#{kind}" : '')
  end
  
  def placed?; self.position?; end
  
  def place(pos)
    self.place!(pos, true)
  end
  
  def place!(pos=nil, without_save=false)
    if other_wid = Widget.find(:first, :conditions => ["user_id = ? AND position = ?", self.user_id, pos])
      other_wid.unplace!
    end
    without_save ? self.position = pos : self.update_attribute(:position, pos)
  end
  
  def unplace!
    self.update_attribute(:position, nil)
  end
  
  def method_missing(method_id, *arguments)
    self.widgetable.send!(method_id, *arguments) rescue super
  end
end

