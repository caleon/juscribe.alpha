class Blog < ActiveRecord::Base
  include_custom_plugins
  
  belongs_to :user # creator
  belongs_to :bloggable, :polymorphic => true
  with_options :class_name => 'Article', :order => 'articles.id DESC', :conditions => "articles.published_at IS NOT NULL AND articles.published_at < NOW()" do |art|
    art.has_many :articles
    art.has_many :latest_articles, :limit => 10
    art.has_one :primary_article
  end
  has_many :pictures, :as => :depictable, :order => 'pictures.position'
  has_one :primary_picture, :class_name => 'Picture', :order => 'pictures.position'
  has_many :comments, :as => :commentable, :order => 'comments.id DESC'
  
  validates_presence_of :bloggable_type, :bloggable_id, :user_id, :name, :short_name, :permalink
  validates_length_of :name, :in => (3..70)
  validates_length_of :short_name, :in => (3..20)
  validates_uniqueness_of :permalink, :scope => [ :bloggable_id, :bloggable_type ]
  validates_with_regexp :name, :short_name, :permalink
  
  attr_protected :permalink
  
  before_save :verify_non_empty_permalink
  
  class << self
    def find_by_user_and_blog(user_id, blog_id)
      User.primary_find(user_id).blogs.primary_find(blog_id) rescue nil
    end
    
    def find_by_group_and_blog(group_id, blog_id)
      Group.primary_find(user_id).blogs.primary_find(blog_id) rescue nil
    end
    
    def primary_find(*args)
      find_by_permalink(*args)
    end
  end
  
  def to_param; self.permalink; end
  def permalink
    self[:permalink] ||= make_permalink
  end
  
  def self.primary_find(*args)
    self.find_by_permalink(*args)
  end
  
  def name=(str)
    self[:name] = str
  end
  
  def short_name=(str)
    self[:short_name] = str
    make_permalink
  end
  
  def to_path(for_associated=false)
    { :"#{for_associated ? 'blog_id' : 'id'}" => self.to_param }.merge(self.bloggable.to_path(true))
  end
  
  def path_name_prefix
    [ self.bloggable.path_name_prefix, 'blog' ].join('_')
  end
  
  def self.permalink_for(name)
    str = name.gsub(/['"]+/i, '').gsub(/[^a-z0-9]+/i, '-').gsub(/-{2,}/, '-').gsub(/^-/, '').gsub(/-$/, '').upcase
    str.chop! if str.last == '-'
    str
  end
    
  private
  def make_permalink(opts={})
    str = Blog.permalink_for(self[:short_name] || self.short_name)
    self.permalink = str
    self.save if opts[:with_save]
    str
  end
  
  def verify_non_empty_permalink
    make_permalink if self[:permalink].blank?
  end
end
