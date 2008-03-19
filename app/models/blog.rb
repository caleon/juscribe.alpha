class Blog < ActiveRecord::Base
  include_custom_plugins
  
  belongs_to :user # creator
  belongs_to :bloggable, :polymorphic => true
  has_many :articles, :order => 'articles.id DESC'
  has_one :primary_article, :class_name => 'Article', :order => 'articles.id DESC'
  has_many :pictures, :as => :depictable, :order => 'pictures.position'
  has_one :primary_picture, :class_name => 'Picture', :order => 'pictures.position'
  has_many :comments, :as => :commentable, :order => 'comments.id DESC'
  
  validates_presence_of :bloggable_type, :bloggable_id, :name, :short_name, :permalink
  validates_length_of :name, :in => (3..70)
  validates_length_of :short_name, :in => (3..12)
  validates_uniqueness_of :permalink, :scope => [ :bloggable_id, :bloggable_type ]
  validates_with_regexp :name, :short_name, :permalink
  
  attr_protected :permalink
  
  before_save :verify_non_empty_permalink
  
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
  
  def content # TODO: this may need better formatting
    recent_article = self.articles.find(:first)
    recent_article.name.to_s + ': ' +
    self.articles.find(:first).content.to_s
  end
  
  #def to_path(for_associated=false)
  #  if self.bloggable.nil?
  #    { :"#{for_associated ? 'blog_id' : 'id'}" => self.to_param }
  #  else
  #    self.to_polypath(for_associated)
  #  end
  #end
  
  def to_path(for_associated=false)
    { :"#{for_associated ? 'blog_id' : 'id'}" => self.to_param }.merge(self.bloggable.nil? ? {} : self.bloggable.to_path(true))
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
