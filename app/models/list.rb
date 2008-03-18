# Submodels are included via the environment.rb file's config.load_paths.
class List < ActiveRecord::Base      
  set_itemizables
  include_custom_plugins  

  belongs_to :user
  
  validates_presence_of :user_id
  validates_associated :items
  validates_with_regexp :name, :permalink
  validates_uniqueness_of :permalink, :scope => :user_id
  
  before_save :verify_non_empty_permalink
  
  STYLES = %w( cardinal ordinal roman numerical dashed dotted )
  
  def name; self[:name] || "Untitled List"; end
  
  def self.to_param
    self.permalink
  end
  def permalink
    self[:permalink] ||= make_permalink
  end
  
  def to_path
    { :user_id => self.user.to_param, :id => self.to_param }
  end
  
  def path_name_prefix
    [ self.user.path_name_prefix, 'list' ]
  end
  
  def self.primary_find(pmlink, opts={})
    find(:first, opts.merge(:conditions => ["lists.permalink = ?", pmlink]))
  end
  
  def self.permalink_for(name)
    str = name.gsub(/['"]+/i, '').gsub(/[^a-z0-9]+/i, '-').gsub(/-{2,}/, '-').gsub(/^-/, '').gsub(/-$/, '')
    str.chop! if str.last == '-'
    str
  end
  
  private
  def make_permalink(opts={})
    str = List.permalink_for(self[:name] || self.name)
    self.permalink = str
    self.save if opts[:with_save]
    str
  end
    
  def verify_non_empty_permalink
    make_permalink if self[:permalink].blank?
  end  
end
