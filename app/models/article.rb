class Article < ActiveRecord::Base
  include_custom_plugins
  acts_as_commentable
  
  is_indexed :fields => [ 'title', 'content' ]
  
  belongs_to :user # creator
  belongs_to :blog, :inherits_layout => true
  
  belongs_to :original, :class_name => 'Article', :foreign_key => :original_id
  has_many :responses, :class_name => 'Article', :foreign_key => :original_id, :order => "articles.published_at DESC"
  def continuations
    self.responses.find(:all, :conditions => ["user_id = ?", self.user_id])
  end
    
  validates_presence_of :blog_id, :user_id, :title, :permalink, :content
  validates_length_of :title, :in => (3..70)
  validate do |article|
    # FIXME: This failed when I set a past publication date on a draft.
    # could be because of #publish= method
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
  
  # A class method for articleshelper
  def self.default_lede_tag
    "(#{APP[:name].upcase})"
  end
  
  def lede_tag
    ((blog && blog.premium? && (self[:lede_tag] || blog.lede_tag)) || Article.default_lede_tag).upcase
  end
  
  def lede_tag=(val)
    val = nil if val.blank?
    self[:lede_tag] = val
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
  
  def author; self.blog.bloggable; end
  
  def imported?; self.imported_at?; end
  def draft?; !self.published_at? && !self.published_date?; end
  def published?; self.published_at? && self.published_date?; end
  def publish!
    unless self.published?
      was_new_record = self.new_record?
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
    # FIXME: Users who press "Public Now" when they schedule something for post will not
    # get the desired effect because this calls #publish on self...
    self.publish if [ "Publish Now", "yes", "Yes", "y", "Y", "1", 1, "true", true].include?(val)
  end
    
  def widgetable?; self.published?; end
  
  def accessible_by?(user)
    (user && user.admin?) || self.user == user ||
    (self.draft? && (self.editable_by?(user) || self.blog.editable_by?(user))) ||
    (!self.draft? && !future_publication? && super)
  end
  
  def comments_for(paragraph_hash)
    if self.comments.loaded?
      self.comments.select{|com| com.paragraph_hash == paragraph_hash }
    else
      self.comments.find(:all, :conditions => ["comments.paragraph_hash = ?", paragraph_hash], :order => 'comments.id ASC')
    end
  end
  
  def composite_tags
    (self.tags + self.blog.tags).uniq
  end
  
  def composite_taggings
    (self.taggings + self.blog.taggings).inject([]) {|arr, tg| arr << tg unless arr.map(&:tag_id).include?(tg.tag_id); arr }
  end
  
  def tag_list
    self.composite_tags.map(&:name).join(", ")
  end
  
  # Refer to commentable.rb as well as the private section of this model file.
  def allows_comments?
    self.blog.allows_comments? && super
  end
  
  def allows_anonymous_comments?
    self.blog.allows_anonymous_comments? && super
  end
  
  def find_all_neighbors(opts={})
    opts[:limit] ||= 5
    prev_articles = self.blog.articles.find(:all, :limit => opts[:limit], :order => 'articles.published_at DESC', :conditions => ["articles.published_at < ?", self.published_at])
    next_articles = self.blog.articles.find(:all, :limit => opts[:limit], :order => 'articles.published_at ASC', :conditions => ["articles.published_at > ?", self.published_at])
    return [ prev_articles, next_articles ]
  end
  
  # TODO: The following can be set with has_many and we can :include them.
  def find_neighbors(opts={})
    @neighbors ||= self.find_all_neighbors(:limit => 1).map {|array_or_res| array_or_res.first rescue array_or_res }
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
  
  def find_similar(limit=5, options={})
    raise "Unauthorized SQL injection attempt!" unless limit.is_a?(Fixnum)
    comp_taggings = (self.taggings + self.blog.taggings).uniq.map(&:id)
    Article.find_by_sql(
      "SELECT unioned.*, sum(pre_similar_count) AS similar_count FROM ( " + 
        "SELECT count(t2.id) AS pre_similar_count, " + 
        "articles.* " + 
        "FROM taggings t1 " + 
        "INNER JOIN taggings t2 ON (t2.tag_id = t1.tag_id) " + 
        "INNER JOIN articles ON (t2.taggable_type = 'Article' AND t2.taggable_id = articles.id) " + 
        "WHERE ((t1.taggable_type = 'Article' AND t1.taggable_id = #{self.id}) AND (t2.taggable_id != #{self.id})) " + 
        "GROUP BY articles.id " + 
        "UNION " + 
        "SELECT count(t3.id) AS pre_similar_count, " + 
        "articles.* " + 
        "FROM taggings t1 " + 
        "INNER JOIN taggings t3 ON (t3.tag_id = t1.tag_id) " + 
        "INNER JOIN blogs ON (t3.taggable_type = 'Blog' AND t3.taggable_id = blogs.id) " + 
        "INNER JOIN articles ON (articles.blog_id = blogs.id) " + 
        "WHERE ((t1.id IN(#{comp_taggings.join(', ')})) AND articles.id != #{self.id} AND articles.published_at IS NOT NULL) " + 
        "GROUP BY articles.id " +
        (options[:threshold] ? "HAVING similar_count > #{options[:threshold]} " : "") + 
      ") unioned GROUP BY unioned.id ORDER BY similar_count DESC, unioned.published_at DESC LIMIT #{limit}"
    )
  rescue
    []
  end
  
  def self.motd
    find(:first, :conditions => ["articles.user_id IN (#{User.admin_ids.join(', ')}) AND articles.published_at IS NOT NULL AND articles.published_at > ?", 1.week.ago.to_formatted_s(:db)], :order => 'articles.id DESC') rescue nil # because User.admin_ids might be empty
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
  
  def default_allows_comments?; self.blog.allows_comments?; end
  def default_allows_anonymous_comments?; self.blog.allows_anonymous_comments?; end
end
