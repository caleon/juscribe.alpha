class Tag < ActiveRecord::Base
  has_many :taggings

  before_save :downcase_tag_name

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_with_regexp :name
  
  def self.primary_find(*args)
    find_by_name(args)
  end
  
  def self.parse(list)
    tag_names = []

    # first, pull out the quoted tags
    list.gsub!(/\"(.*?)\"\s*/ ) { tag_names << $1; "" }

    # then, replace all commas with a space
    #list.gsub!(/,/, " ")

    # then, get whatever's left
    tag_names.concat list.split(/,/)

    # strip whitespace from the names
    tag_names = tag_names.map { |t| t.strip }

    # delete any blank tag names
    tag_names = tag_names.delete_if { |t| t.empty? }

    return tag_names
  end
  
  def to_param
    self.name
  end

  def tagged
    @tagged ||= taggings.collect { |tagging| tagging.taggable }
  end

  def on(taggable, opts={})
    taggings.create(opts.merge(:taggable => taggable))
    self
  end

  def ==(comparison_object)
    super || self.name == comparison_object.to_s
  end

  def to_s
    self.name
  end

  private
  def downcase_tag_name
    self.name = self.name.downcase
  end
  
end
