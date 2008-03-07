class Picture < ActiveRecord::Base
  acts_as_itemizable :gallery
  include PluginPackage

  belongs_to :user
  belongs_to :depictable, :polymorphic => true

  validates_presence_of :depictable_type, :depictable_id, :user_id
    
  def file_path(size=nil) # TODO: symlink uploads directory in images to shared one.
    "uploads/" + self.depictable_type + '/' + self.id.to_s + ".jpg"
  end
  
end
