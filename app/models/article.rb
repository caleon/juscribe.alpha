class Article < ActiveRecord::Base
  include_custom_plugins  
  
  belongs_to :user # creator
  belongs_to :blog, :inherits_layout => true
  has_many :comments, :as => :commentable
    
  validates_presence_of :blog_id, :user_id, :title, :permalink, :content
  validates_length_of :title, :in => (3..70)
  validate do |article|
    article.errors.add(:published_at, "must be in the future") unless (article.published? || article.published_at.nil? || article.published_at > Time.now)
  end
  validates_uniqueness_of :permalink, :scope => :blog_id
  validates_with_regexp :permalink, :title, :message => "uses an incorrect format: please edit your title"
  validates_with_regexp :content
  
  attr_protected :permalink, :published_date, :published_at
  alias_attribute :name, :title # Content is already correct for widget
  
  before_save :verify_non_empty_permalink
  
  def to_s; self.title; end
  def to_param; self.permalink; end
  def display_name; self.title; end
  def permalink
    self[:permalink] ||= make_permalink
  end
  
  def title=(str)
    self[:title] = str.strip
    make_permalink
  end
  
  def to_path(for_associated=false)
    if self.draft?
      { :"#{for_associated ? 'article_id' : 'id'}" => self.to_param }.merge(self.blog.to_path(true))
    else
      date = self.published_date
      { :year => date.year.to_s, :month => sprintf("%02d", date.month), :day => sprintf("%02d", date.day),
        :"#{for_associated ? 'article_id' : 'id'}" => self.to_param }.merge(self.blog.to_path(true))
    end
  end
  
  def path_name_prefix
    [ self.blog.path_name_prefix, self.published? ? 'article' : 'draft' ].join('_')
  end
  
  def import?; self.imported_at?; end
  def draft?; !self.published_at? && !self.published_date?; end
  def published?; self.published_at? && self.published_date?; end
  def publish!
    unless self.published?
      publish
      self.save!
    end
  end
  def publish
    self.published_date, self.published_at = [ Date.today, Time.now ] unless self.published?
  end
  def unpublish!
    unless self.draft?
      self.published_date, self.published_at = [ nil, nil ]
      self.save!
    end
  end
  def publish_at
    self.published_at
  end
  def future_publication?
    !self.published_at.nil? && self.published_at > Time.now
  end
  def publish_at=(datetime)
    self.published_date, self.published_at = datetime.to_date, datetime
  end
  def publish=(val) # This is for automatically setting published fields from form data.
    self.publish if [ "Publish Now", "yes", "Yes", "y", "Y", "1", 1, "true", true].include?(val)
  end
    
  def widgetable?; self.published?; end
  
  def accessible_by?(user)
    (user && user.admin?) || self.user == user ||
    (self.draft? && (self.editable_by?(user) || self.blog.editable_by?(user))) ||
    (!self.draft? && !future_publication? && super)
  end
    
  def self.primary_find(*args); find_by_params(*args); end
  
  def self.find_by_params(params, opts={})
    params.symbolize_keys!
    for_association = opts.delete(:for_association)
    if params[:year].blank?
      if params[:user_id]
        author = User.primary_find(params[:user_id])
      elsif params[:group_id]
        author = Group.primary_find(params[:group_id])
      end
      author.blogs.primary_find(params[:blog_id]).drafts.find_by_permalink(params[:article_id] || params[:id])
    else
      date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i) rescue (raise params.inspect)
      return nil unless (author = User.primary_find(params[:user_id]) || Group.primary_find(params[:group_id])) and blog = author.blogs.primary_find(params[:blog_id])
      find(:first, { :conditions => ["articles.blog_id = ? AND articles.published_date = ? AND articles.permalink = ?", blog.id, date.to_formatted_s(:db), for_association ? params[:article_id] : params[:id] ] }.merge(opts))
    end
  end
  
  def self.find_any_by_permalink_and_nick(permalink, nick, opts={})
    if user = User.find_by_nick(nick)
      find_all_by_permalink_and_user_id(permalink, user.id, opts)
    else
      []
    end
  end
  
  def self.motd
    find(:first, :conditions => ["articles.user_id IN (#{User.admin_ids.join(', ')})"], :order => 'articles.id DESC')
  end
  
  def self.permalink_for(name)
    str = name.gsub(/['"]+/i, '').gsub(/[^a-z0-9]+/i, '-').gsub(/-{2,}/, '-').gsub(/^-/, '').gsub(/-$/, '')
    str.strip!
    str.chop! if str.last == '-'
    str
  end
  
  private
  def make_permalink(opts={})
    str = Article.permalink_for(self[:title] || self.name)
    self.permalink = str
    self.save if opts[:with_save]
    str
  end
    
  def verify_non_empty_permalink
    make_permalink if self[:permalink].blank?
  end
end
