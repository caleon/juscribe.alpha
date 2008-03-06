class Picture < ActiveRecord::Base
  validates_presence_of :depictable_type, :depictable_id, :user_id
  validates_presence_of :position, :if => !self.gallery.nil?
  
  def file_path # TODO: symlink uploads directory in images to shared one.
    "uploads/" + self.depictable_type + '/' + self.id.to_s + ".jpg"
  end
end
