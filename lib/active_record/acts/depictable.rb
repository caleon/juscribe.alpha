module ActiveRecord::Acts::Depictable
  def self.included(base)
    base.extend(ClassMethods)  
  end

  module ClassMethods
    def acts_as_depictable(options = {})
      with_options :class_name => 'Picture', :as => :depictable, :order => :position do |pic|
        pic.has_many :pictures, :dependent => :nullify, :conditions => 'pictures.thumbnail IS NULL'
        pic.has_one :front_picture, :conditions => 'pictures.thumbnail IS NULL'
        pic.has_many :thumbs, :conditions => ["pictures.thumbnail = ?", 'thumb']
      end   
      
      include ActiveRecord::Acts::Depictable::InstanceMethods
    end
  end
  
  module InstanceMethods
    def primary_picture
      front_picture.thumbnails.find_by_thumbnail('feature')
    end # i'm not liking the fact that three DB rows are created per pic. Plus updating attributes
    # on one doesn't guarantee others are affected. Need to rethink this.
    
    # TODO: Finish rethinking and redo this.
  end
end

# 1) Make subclasses of Picture for Thumbnail. Create column "type" in pictures table. Define scoped find conditions here.
# 2) Make separate table for Thumbnails using almost same columns as Pictures
# 3) Subclass into UserPicture, ArticlePicture, etc. (doesn't solve issue of too huge a db table)