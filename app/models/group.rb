class Group < ActiveRecord::Base
  include PluginPackage
  
  belongs_to :user
  has_many :memberships
  has_many :users, :through => :memberships do
    def admin
      find(:all, :conditions => ["memberships.rank >= ?", Membership::ADMIN_RANK])
    end
  end
  has_many :pictures, :as => :depictable
  
  validates_presence_of :name, :user_id
  validates_uniqueness_of :name
  validates_length_of :name, :in => (3..20)
  validates_format_of :name, :with => /^[^\s].+[^\s]$/i
  
  attr_protected :rank
    
  def editable_by?(user)
    self.users.admin.include?(user)
  end
  
  def accessible_by?(user)
    self.users.include?(user) || super
  end
  
  def membership_for(user)
    mem = self.memberships.find(:first, :conditions => ["user_id = ?", user.id])
    raise ActiveRecord::RecordNotFound unless mem
    mem
  rescue ActiveRecord::RecordNotFound
    msg = "#{user.internal_name} not a member of #{self.internal_name}"
    self.errors.add_to_base(msg)
    raise ActiveRecord::RecordNotFound, msg
  end
  
  def has_member?(user)
    true if self.membership_for(user) rescue false
  end
  
  def rank_for(user)
    self.membership_for(user).rank
  end
  
  def assign_rank(user, rank=nil)
    mem = self.membership_for(user)
    mem.rank = rank
    if mem.rank >= 0 && mem.rank <= 10  && mem.save
      mem
    else
      false
    end
  rescue ActiveRecord::RecordNotFound => e
    self.errors.add_to_base(e.message)
    return false
  end
  
  # Ex: group.join(user, {:title => 'Captain', :rank => 3})
  # =>  group.join(:user_id => 3, :title => 'Colonel', :rank => 2)
  def join(*args)
    attrs = args.extract_options!
    raise ArgumentError, "Invalid argument for joining Group" unless (args.first.is_a?(User) || attrs[:user_id]) 
    user = args.shift
    attrs[:user_id] ||= user.id
    user ||= User.find(attrs[:user_id])
    raise LimitError, "#{user.internal_name} has reached the maximum number of groups one can join (#{APP[:limits][:memberships]}). Please contact #{APP[:contact]} to resolve this issue." if user.groups.count >= APP[:limits][:memberships]
    mem = self.memberships.new(attrs)
    mem.rank = attrs[:rank] # This is a protected attribute. Needs to be set like this.
    mem.save!
    true
  rescue ArgumentError => e
    self.errors.add_to_base(e.message)
    return false
  rescue LimitError => e
    self.errors.add_to_base(e.message)
    return false
  rescue ActiveRecord::RecordInvalid
    self.errors.add_to_base("#{user.internal_name} already a member of #{self.internal_name}")
    return false
  end
  
  def kick(user)
    mem = self.membership_for(user)
    Notifier.deliver_group_leave_notification(user) if mem.destroy
  rescue ActiveRecord::RecordNotFound => e
    self.errors.add_to_base(e.message)
    return false
  end
  
  def announce(user, message)
    
  end
  
  def disband!
    Notifier.deliver_group_disband_notification(self)
    Membership.delete_all("group_id = #{self.id}")
    self.destroy
  end

end
