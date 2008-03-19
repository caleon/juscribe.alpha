class User < ActiveRecord::Base
  has_many :articles, :dependent => :nullify
  has_many :owned_blogs, :class_name => 'Blog', :dependent => :nullify
  has_many :blogs, :as => :bloggable, :dependent => :nullify
  has_many :entries, :dependent => :nullify
  has_one :latest_entry, :class_name => 'Entry', :order => 'entries.id DESC'
  has_many :songs, :dependent => :nullify
  has_many :events, :dependent => :nullify
  has_many :projects, :dependent => :nullify
  has_many :messages, :foreign_key => 'recipient_id', :dependent => :nullify,
           :order => 'messages.id DESC'
  has_many :sent_messages, :class_name => 'Message', :foreign_key => 'sender_id',
           :order => 'messages.id DESC'
  has_many :owned_taggings, :class_name => 'Tagging', :dependent => :nullify
  has_many :owned_pictures, :class_name => 'Picture', :dependent => :nullify
  has_many :galleries, :order => 'galleries.id DESC'
  has_many :permission_rules, :order => 'permission_rules.id DESC'
  has_many :pictures, :as => :depictable, :order => :position, :dependent => :nullify
  has_one :primary_picture, :class_name => 'Picture', :as => :depictable, :order => :position
  has_many :memberships, :dependent => :destroy
  has_many :groups, :through => :memberships
  has_many :owned_groups, :class_name => 'Group', :dependent => :nullify
  has_many :widgets, :order => :position, :dependent => :nullify do
    def placed(limit=nil)
      find(:all, :conditions => "position IS NOT NULL", :limit => limit)
    end
    def unplaced(limit=nil)
      find(:all, :conditions => "position IS NULL", :limit => limit)
    end 
  end
  has_many :favorite, :class_name => 'Favorite',
                      :order => 'id desc', :dependent => :nullify do
    def articles; find(:all, :conditions => "responsible_type = 'Article'"); end
    def comments; find(:all, :conditions => "responsible_type = 'Comment'"); end
    def entries; find(:all, :conditions => "repsonsible_type = 'Entry'"); end
    def projects; find(:all, :conditions => "responsible_type = 'Project'"); end
    def pictures; find(:all, :conditions => "responsible_type = 'Picture'"); end
    def groups; find(:all, :conditions => "responsible_type = 'Group'"); end
  end
  
  def primary_picture_path
    self.primary_picture.file_path
  rescue NoMethodError
    nil
  end
end