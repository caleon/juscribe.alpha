class PermissionRule < ActiveRecord::Base
  
  # data will be a serialized hash in the form of:
  #   { :allowed => {:user => [1, 2, 3], :group => [34, 5]},
  #     :denied => {:user => [4, 5], :group => []}}
  serialize :allowed
  serialize :denied
  serialize :bosses
  serialize :options
  before_save :check_integrity
  
  #has_many :permissions
  has_many :users
  has_many :blogs
  has_many :articles
  has_many :comments
  has_many :pictures
  has_many :groups
  has_many :galleries
  has_many :projects
  has_many :events

  belongs_to :user
  
  
  VALID_TYPES = [ :user, :group ]
  DEFAULTS = { :allowed => { :user => [], :group => [] },
               :denied => { :user => [], :group => [] },
               :bosses => { :user => [], :group => [] },
               :options => { :comments => nil, :anonymous_comments => nil } }
  PASTS = { :allow => :allowed, :deny => :denied, :boss => :bosses }
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :user_id, :allow_nil => true
  validates_with_regexp :name
  
  def to_path
    { :id => self.to_param }
  end
  
  def public?; !self.private? && (self.denied[:user].empty? && self.denied[:group].empty?); end
  def protected?; !self.private? && (!self.denied[:user].empty? || !self.denied[:group].empty?); end
  
  def toggle_privacy!
    raise "Cannot modify public_rule!" if id == DB[:public_rule]
    self.toggle!(:private)
  end
  
  def accessible_by?(user=nil)
    if user.is_a?(Fixnum)
      begin
        user = User.find(user)
      rescue
        return false
      end
    end
    if self.public? || (user && user.admin?)
      return true
    elsif self.protected?
      return false if user.nil?
      return self.user == user ||
             self.bosses[:user].include?(user.id) ||
             !(self.bosses[:group] & user.group_ids).empty? ||
             (!self.denied[:user].include?(user.id) &&
             (self.denied[:group] & user.group_ids).empty?)
    elsif self.private?
      return false if user.nil?
      return self.user == user ||
             self.bosses[:user].include?(user.id) ||
             !(self.bosses[:group] & user.group_ids).empty? ||
             !(self.allowed[:group] & user.group_ids).empty? ||
             self.allowed[:user].include?(user.id)
    end
    false
  end
  
  def editable_by?(user=nil)
    self.user = user
  end
  
  def name; self[:name] || "Untitled"; end
  
  # The following prevents needing to input filler data in serialized hash
  def allowed; DEFAULTS[:allowed].merge(self[:allowed] || {}); end
  def denied; DEFAULTS[:denied].merge(self[:denied] || {}); end
  def bosses; DEFAULTS[:bosses].merge(self[:bosses] || {}); end
  def options; DEFAULTS[:options].merge(self[:options] || {}); end
  
  def set_option!(key, val)
    raise "Cannot modify public_rule!" if id == DB[:public_rule]
    self.options = self.options.merge(key => val)
    self.save!
  end
  
  def get_option(key)
    self.options[key]
  end
  
  def reset_options!
    raise "Cannot modify public_rule!" if id == DB[:public_rule]
    self.options = DEFAULTS[:options]
    self.save!
  end
  
  def whitelist!(*args)
    self.allow!(*args)
    self.undo_deny!(*args)
  end
  
  def blacklist!(*args)
    self.deny!(*args)
    self.undo_allow!(*args)
  end
  
  def allow!(*args); add_rule(:allow, args); end
  def deny!(*args); add_rule(:deny, args); end
  def undo_allow!(*args); remove_rule(:allow, args); end
  def undo_deny!(*args); remove_rule(:deny, args); end
  
  def add_boss!(*args); add_rule(:boss, args); end
  def remove_boss!(*args); remove_rule(:boss, args); end
      
  def apply_to!(permissible)
    raise ArgumentError, 'Target not a permissible type' unless permissible.respond_to?(:rule)
    permissible.update_attribute(:permission_rule_id, id)
  end
  
  def duplicate(attrs={})
    new_attrs = self.attributes.merge(attrs) # Duplicated names will be mentioned in errors.
    new_attrs[:name] = self.name + ' copy' if !self.name.blank? && attrs[:name].blank?
    PermissionRule.create(attrs)
  end
  
  #def reassign_all_to!(rule, opts={})
  #  Permission.update_all("permission_rule_id = #{rule.id}", ["permission_rule_id = ?", self.id])
  #  self.reload
  #  self.destroy if opts[:delete]
  #  rule.reload
  #end
  
  private  
  def check_integrity
    true # TODO: stubbed. also should probably compact arrays
  end

  def add_rule(act, args); rule_helper(act, args, :|); end
  def remove_rule(act, args); rule_helper(act, args, :-); end
  def rule_helper(act, args, proc)
    raise "Cannot modify public_rule!" if id == DB[:public_rule]
    
    raise ArgumentError, 'Need to specify permittable type' unless VALID_TYPES.include?(args.first)
    kind, hash = args.shift, self.send(PASTS[act]) # kind is :user, hash is formatted
    self[PASTS[act]] = hash.merge(kind => hash[kind].send(proc, args.map(&:to_id))) # NOTE: to_id is used HERE!
    self.save!
    self.reload
  end

end
