class Article < ActiveRecord::Base
  include PluginPackage
  
  belongs_to :user
  has_many :pictures, :as => :depictable
    
  validates_presence_of :user_id, :title, :permalink, :content
  validates_length_of :title, :in => (3..50)
  validates_uniqueness_of :permalink, :scope => :user_id
  validates_format_of :permalink, :with => /[-_a-z0-9]{3,}/i,
                      :message => "is already taken: please edit your title"
  validates_format_of :title, :with => /^[^\s].+[^\s]$/i
  validates_format_of :content, :with => /^[^\s].+[^\s]$/i
  
  def name; self.title; end
  def to_param; self.permalink; end
  def to_s; self.title; end
  
  def draft?; !self.published_time?; end
  def published?; self.published_time?; end
  def publish!
    time = Time.now
    self.published_date, self.published_time = [ time, time ]
    self.save!
  end
  def unpublish!
    self.published_date, self.published_time = [ nil, nil ]
    self.save!
  end
  def published_at
    self.published_date.to_formatted_s(:rfc822) + ', ' + self.published_time.to_s(:time)
  end
  
  def title=(str)
    self[:title] = str
    make_permalink
  end
  
  def self.find_with_url(user_id, year, month, day, permalink, opts={})
    date = Date.parse("#{year}/#{month}/#{day}")
    find(:all, { :conditions => [ "articles.user_id = ? AND published_date = ? AND permalink = ?",
                                  user_id, date.to_formatted_s(:db), permalink ] }.merge(opts)).first
  end

  def self.find_by_date(year, month, day)
    date = Date.parse("#{month}/#{day}/#{year}")
    find(:all, :conditions => [ 'published_date = ?', date ])
  end
  
    
  private
  def make_permalink(opts={})
    str = (opts[:title] || self.title).gsub(/['"]+/i, '').gsub(/[^a-z0-9]+/i, '-')
    str.chop! if str.last == "-"
    self.permalink = str unless opts[:with_save]
  end
     
end
