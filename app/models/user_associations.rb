class User < ActiveRecord::Base
  has_many :articles
  has_many :entries
  has_many :songs
  has_many :events
  has_many :projects
  has_many :messages, :foreign_key => 'recipient_id', :conditions => "sent IS TRUE",
           :order => 'id DESC'
  has_many :sent_messages, :class_name => 'Message', :foreign_key => 'sender_id',
           :conditions => "sent IS TRUE", :order => 'id DESC'
  has_many :drafts, :class_name => 'Message', :foreign_key => 'sender_id',
           :conditions => "sent IS FALSE", :order => 'id DESC'
  has_many :owned_taggings, :class_name => 'Tagging'
  has_many :owned_pictures, :class_name => 'Picture'
  has_many :pictures, :as => :depictable, :order => :position
  has_one :primary_picture, :class_name => 'Picture', :foreign_key => 'depictable_id',
          :conditions => ["depictable_type = ?", 'User']
  has_many :memberships
  has_many :groups, :through => :memberships
  has_many :owned_groups, :class_name => 'Group'
  has_many :widgets, :order => :position do
    def placed(limit=nil)
      find(:all, :conditions => "position IS NOT NULL", :limit => limit)
    end
    def unplaced(limit=nil)
      find(:all, :conditions => "position IS NULL", :limit => limit)
    end 
  end
  has_many :favorite, :class_name => 'Favorite', :order => 'id desc' do
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