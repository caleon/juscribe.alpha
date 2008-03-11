class Article < ActiveRecord::Base
  include PluginPackage
  
  belongs_to :user
  has_many :pictures, :as => :depictable
    
  validates_presence_of :user_id, :title, :permalink, :content
  validates_length_of :title, :in => (3..100)
  validates_uniqueness_of :permalink, :scope => :user_id # Hm this, or published_date?
  
  validates_with_regexp :permalink, :message => "uses an incorrect format: please edit your title"
  validates_with_regexp :title
  validates_with_regexp :content
  
  def to_s; self.title; end
  def name; self.title; end
  def to_param; self.permalink; end
  
  def hash_for_path
    if self.draft?
      { :permalink => self.to_param, :nick => self.user.to_param }
    else
      date = self.published_date
      { :year => date.year, :month => sprintf("%02d", date.month), :day => sprintf("%02d", date.day),
        :nick => self.user.to_param, :permalink => self.to_param }
    end
  end
  
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
  
  def self.primary_find(*args); find_by_params(*args); end
  def self.find_by_nick_and_path(nick, path, opts={})
    year, month, day, permalink = path.split('/')
    date = Date.new(year.to_i, month.to_i, day.to_i)
    user = User.find_by_nick(nick)
    find(:first, { :conditions => [ "articles.user_id = ? AND published_date = ? AND permalink = ?",
                                  user.id, date.to_formatted_s(:db), permalink ] })
  end
  
  def self.find_by_path(path, opts={})
    year, month, day, permalink, filler, nick = path.split('/')
    date = Date.new(year.to_i, month.to_i, day.to_i)
    user = User.find_by_nick(nick)
    find(:first, :conditions => [ "articles.user_id = ? AND published_date = ? AND permalink = ?",
                                  user.id, date.to_formatted_s(:db), permalink ])
  end
  
  def self.find_by_params(params, opts={})
    params.symbolize_keys!
    date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    user = User.find_by_nick(params[:nick])
    find(:first, { :conditions => [ "articles.user_id = ? AND published_date = ? AND permalink = ?", user.id, date.to_formatted_s(:db), params[:permalink]] })
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
  
  def self.find_by_permalink_and_nick(permalink, nick)
    if user = User.find_by_nick(nick)
      find_by_permalink_and_user_id(permalink, user.id, :conditions => "published_date IS NOT NULL")
    end
  end
    
  def self.find_all_by_permalink_and_nick(permalink, nick)
    if user = User.find_by_nick(nick)
      find_all_by_permalink_and_user_id(permalink, user.id, :conditions => "published_date IS NOT NULL")
    else
      []
    end
  end
  
  # Gets rid of quotation marks, replaces all non-alphanumeric characters
  # with dashes, removes multiple adjacent dashes, strips dashes from
  # beginning and end.
  def self.permalink_for(title)
    str = title.gsub(/['"]+/i, '').gsub(/[^a-z0-9]+/i, '-').gsub(/-{2,}/, '-').gsub(/^-/, '').gsub(/-$/, '')
    str.chop! if str.last == '-'
    str
  end
    
  private
  def make_permalink(opts={})
    str = Article.permalink_for(opts[:title] || self.title)
    self.permalink = str
    self.save if opts[:with_save]
  end
     
end
