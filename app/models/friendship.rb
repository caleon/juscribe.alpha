class User < ActiveRecord::Base
  serialize :friend_ids
  
  def friends_with?(user)
    self.friend_ids.include?(user.id) && user.friend_ids.include?(self.id)
  end
  
  def friend_ids; self[:friend_ids].to_a; end
  
  def friends
    @friends ||= User.find(self.friend_ids)
  end
  
  def befriend(*args)
    raise ArgumentError unless ((user = args.shift).is_a?(User) && user != self)
    raise FriendshipError.new(:already, self, user) if self.friends_with?(user)
    raise FriendshipError.new(:pending, self, user) if self.friend_ids.include?(user.id)
    opts = args.extract_options!
    new_friend_ids = self.friend_ids | [user.to_id]
    (@friends ||= []) << user
    if opts[:save] ||= true
      self[:friend_ids] = new_friend_ids
      self.save!
      Notifier.deliver_friendship_request(user, :friend_id => self.id)
    else
      self.friend_ids = new_friend_ids
    end
    self.friends_with?(user) ? 1 : 0
  rescue ArgumentError
    self.errors.add_to_base("Invalid argument for befriending")
    false
  rescue FriendshipError => e
    e.add_error
    false
  rescue ActiveRecord::RecordInvalid
    false
  end
  
  def unfriend(user)
    self[:friend_ids] = self.friend_ids - [user.id]
    @friends = (@friends ||= []) - [user]
    self.save
  end
  
  def common_friends_with(user)
    User.find(self.friend_ids & user.friend_ids)
  end
end
