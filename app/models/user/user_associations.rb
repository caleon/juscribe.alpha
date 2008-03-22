class User < ActiveRecord::Base
  with_options :class_name => 'Article', :conditions => "articles.published_at IS NOT NULL AND articles.published_at < NOW()", :order => 'articles.id DESC' do |art|
    art.has_many :articles, :dependent => :nullify
    art.has_many :latest_articles, :limit => 10
  end
  has_many :drafts, :class_name => 'Article', :dependent => :nullify,
                    :conditions => "published_date IS NULL"
  has_many :all_articles, :class_name => 'Article', :order => 'articles.id DESC'
  has_many :owned_blogs, :class_name => 'Blog', :dependent => :nullify
  has_many :blogs, :as => :bloggable, :dependent => :nullify
  def all_blogs; (owned_blogs + blogs).uniq; end
  has_many :comments, :as => :commentable, :order => 'comments.id DESC'
  has_many :owned_comments, :class_name => 'Comment', :dependent => :nullify
  with_options :class_name => 'Entry', :order => 'entries.id DESC' do |entry|
    entry.has_many :entries, :dependent => :nullify
    entry.has_many :latest_entries, :limit => 10
    entry.has_one :latest_entry
  end
  has_many :songs, :dependent => :nullify
  has_many :events, :dependent => :nullify, :order => 'events.begins_at DESC'
  has_many :upcoming_events, :class_name => 'Event', :order => 'events.begins_at DESC',
                             :limit => 10
  has_many :projects, :dependent => :nullify
  has_many :messages, :foreign_key => 'recipient_id', :dependent => :nullify,
           :order => 'messages.id DESC' do
             def unread; find(:all, :conditions => [ "`read` = ?", false ]); end
           end
  has_many :sent_messages, :class_name => 'Message', :foreign_key => 'sender_id',
           :order => 'messages.id DESC'
  has_many :owned_taggings, :class_name => 'Tagging', :dependent => :nullify
  has_many :owned_pictures, :class_name => 'Picture', :dependent => :nullify
  has_many :latest_pictures, :class_name => 'Picture', :order => 'pictures.id DESC', :limit => 10
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
  has_many :placed_widgets, :class_name => 'Widget', :order => :position, :dependent => :nullify,
                            :conditions => "position IS NOT NULL"
  has_many :unplaced_widgets, :class_name => 'Widget', :order => :position, :dependent => :nullify,
                              :conditions => "position IS NULL"
    
  
  def primary_picture_path
    self.primary_picture.file_path
  rescue NoMethodError
    nil
  end
end