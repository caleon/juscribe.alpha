class Song < ActiveRecord::Base
  acts_as_itemizable :scope => :playlist
  include_custom_plugins  

  belongs_to :user
  
  validates_presence_of :title, :artist, :user_id
  validates_uniqueness_of :permalink, :scope => :list_id
  validates_with_regexp :permalink, :title, :artist
  
  before_save :verify_non_empty_permalink
  
  # For Widget
  alias_attribute :name, :title  
  def content; "\"#{self.title}\" by #{self.artist}"; end
  
  def to_param; self.permalink; end
  def permalink
    self[:permalink] ||= make_permalink
  end
  
  def title=(str)
    self[:title] = str
    make_permalink
  end
  
  def to_path
    { :playlist_id => self.playlist.to_param, :id => self.to_param }
  end
  
  def path_name_prefix
    [ (self.playlist.nil? ? self.user.path_name_prefix : self.playlist.path_name_prefix), 'song' ].join('_')
  end
  
  def self.primary_find(pmlink, opts={})
    self.find(:first, opts.merge(:conditions => ["songs.permalink = ?", pmlink]))
  end
  
  def self.permalink_for(name)
    str = name.gsub(/['"]+/i, '').gsub(/[^a-z0-9]+/i, '-').gsub(/-{2,}/, '-').gsub(/^-/, '').gsub(/-$/, '')
    str.chop! if str.last == '-'
    str
  end
  
  private
  def make_permalink(opts={})
    str = Song.permalink_for(self[:title] || self.title)
    self.permalink = str
    self.save if opts[:with_save]
    str
  end
    
  def verify_non_empty_permalink
    make_permalink if self[:permalink].blank?
  end
  
end
