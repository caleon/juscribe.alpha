class Article < ActiveRecord::Base
  include PluginPackage
  
  belongs_to :user
  has_many :pictures, :as => :depictable
  
  before_save :make_permalink
  
  validates_presence_of :user_id, :title, :permalink, :content
  validates_length_of :title, :in => (3..50)
  validates_uniqueness_of :permalink
  validates_format_of :permalink, :with => /[-_a-z0-9]{3,}/i,
                      :message => "is already taken: please edit your title"
  validates_format_of :title, :with => /^[^\s].+[^\s]$/i
  validates_format_of :content, :with => /^[^\s].+[^\s]$/i
  
  def name; self.title; end
  def to_param; self.permalink; end # This should mean the permalink becomes param[:id]
  
  def publish!; self.published = true; self.save!; end
  def unpublish!; self.published = false; self.save!; end
  
  def title=(str)
    self[:title] = str
    make_permalink
  end
  
  ############ CLASS METHODS ###
  class << self    
    def find_by_permalink(year, month, day, perm)
      month, day = month.to_i, day.to_i
      from, to = time_delta(year, month, day)
      find(:first, :conditions => ['created_at BETWEEN ? AND ? AND ' +
                                   'permalink = ?',
                                   from, to, perm])
    end

    def find_by_date(year, month, day)
      from, to = time_delta(year, month, day)
      find(:all, :conditions => ['created_at BETWEEN ? and ?', from, to])
    end

    protected
    def time_delta(year, month = nil, day = nil)
      from = Time.mktime(year, month || 1, day || 1)
      to = from.next_year
      to = from.next_month unless month.blank?
      to = from + 1.day unless day.blank?
      to -= 1 # pull off 1 second so we don't overlap onto the next day
      return [from, to]
    end
  end
  
    
  #######
  private
  #######
  def make_permalink(opts={})
    str = (opts[:title] || self.title).gsub(/['"]+/i, '').gsub(/[^a-z0-9]+/i, '-')
    str.chop! if str.last == "-"
    self.permalink = str unless opts[:with_save]
  end
     
end
