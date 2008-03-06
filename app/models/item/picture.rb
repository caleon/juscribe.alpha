class Picture < Item
  set_table_name 'pictures'
  
  belongs_to :depictable, :polymorphic => true
  acts_as_list :scope => :depictable

  validates_presence_of :depictable_type, :depictable_id, :user_id
  validates_presence_of :position, :if => :no_gallery?
  
  alias :gallery :list
  alias :gallery= :list=
  
  def file_path(size=nil) # TODO: symlink uploads directory in images to shared one.
    "uploads/" + self.depictable_type + '/' + self.id.to_s + ".jpg"
  end
  
  def no_gallery?
    self.gallery.nil?
  end
  
end
