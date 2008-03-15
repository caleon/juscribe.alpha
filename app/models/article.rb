class Article < ActiveRecord::Base
  include_custom_plugins  
  
  belongs_to :user, :include => :primary_picture
  has_many :pictures, :as => :depictable
  has_many :comments, :as => :commentable
    
  validates_presence_of :user_id, :title, :permalink, :content
  validates_length_of :title, :in => (3..100)
  validates_uniqueness_of :permalink, :scope => :user_id # Hm this, or published_date?
  
  validates_with_regexp :permalink, :title, :message => "uses an incorrect format: please edit your title"
  validates_with_regexp :content
  
  attr_protected :permalink, :published_date, :published_time
  
  before_save :verify_non_empty_permalink
  
  def to_s; self.title; end
  def name; self.title; end
  def to_param; self.permalink; end
  def permalink
    self[:permalink] ||= make_permalink
  end
  
  def title=(str)
    self[:title] = str
    make_permalink
  end
  
  def to_path(for_associated=false)
    if self.draft?
      { :"#{for_associated ? 'article_id' : 'id'}" => self.to_param, :user_id => self.user.to_param }
    else
      date = self.published_date
      { :year => date.year.to_s, :month => sprintf("%02d", date.month), :day => sprintf("%02d", date.day),
        :user_id => self.user.to_param, :"#{for_associated ? 'article_id' : 'id'}" => self.to_param }
    end
  end
  
  def draft?; !self.published_time? && !self.published_date?; end
  def published?; self.published_time? && self.published_date?; end
  def publish!
    unless self.published?
      self.published_date, self.published_time = [ Date.today, Time.now ]
      self.save!
    end
  end
  def unpublish!
    unless self.draft?
      self.published_date, self.published_time = [ nil, nil ]
      self.save!
    end
  end
  def published_at
    return nil unless self.published?
    self.published_date.to_formatted_s(:rfc822) + ', ' + self.published_time.to_s(:time)
  end
  def publish=(val) # This is for automatically setting published fields from form data.
    self.publish! if [ "Publish", "yes", "Yes", "y", "Y", "1", 1, "true", true].include?(val)
  end
  
  def widgetable?; self.published?; end
  
  def self.primary_find(*args); find_by_params(*args); end
  
  def self.find_by_params(params, opts={})
    for_association = opts.delete(:for_association)
    params.symbolize_keys!
    debugger
    date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    return nil unless user = User.find_by_nick(params[:user_id])
    find(:first, { :conditions => [ "articles.user_id = ? AND published_date = ? AND permalink = ?", user.id, date.to_formatted_s(:db), for_association ? params[:article_id] : params[:id]] })
  end
  
  def self.find_any_by_permalink_and_nick(permalink, nick, opts={})
    if user = User.find_by_nick(nick)
      find_all_by_permalink_and_user_id(permalink, user.id, opts)
    else
      []
    end
  end
  
  def self.permalink_for(name)
    str = name.gsub(/['"]+/i, '').gsub(/[^a-z0-9]+/i, '-').gsub(/-{2,}/, '-').gsub(/^-/, '').gsub(/-$/, '')
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
