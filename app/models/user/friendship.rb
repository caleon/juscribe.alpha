module Friendship
  def self.included(klass)
    klass.class_eval(%{serialize :friend_ids})
  end
  
  def friends_with?(user)
    self != user && self.friend_ids.include?(user.id) && user.friend_ids.include?(self.id)
  end
  
  def kinda_friends_with?(user)
    self != user && self.friend_ids.include?(user.id)
  end
      
  def friend_ids; self[:friend_ids].to_a; end
  
  def friends(opts={})
    @friends ||= User.find(self.friend_ids, opts).select {|frnd| self.friends_with?(frnd)} # do opts.delete(:limit) and raise it by a
                          # buffer for the SQL, then release the number of
                          # results desired by subselecting the array...
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
      Notifier.deliver_friendship_request(user, :friend_id => self.id) unless self.friends_with?(user)
    else
      self.friend_ids = new_friend_ids
      # Needs to deliver request email separately.
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
  
  
  class FriendshipError < StandardError
    class MsgSet
      def initialize(field, msg, *vars)
        @arr = [field, msg, *vars]
      end

      def field; @arr[0]; end
      def msg_str; @arr[1]; end
      def users; @arr[2..-1]; end

      def message(user, friend)
        hash = {:user => user, :friend => friend}
        msg_str % users.map{|sym| hash[sym].internal_name }
      end

      def error_args(user, friend)
        field ? [:add, field, message(user, friend)] : [:add_to_base, message(user, friend)]
      end
    end

    MESSAGES = { :forbidden   =>  MsgSet.new(nil, "Friendship requests are forbidden"),
                 :pending     =>  MsgSet.new(:friend_ids, "is invalid: %s already has a friendship request with %s", :user, :friend),
                 :already     =>  MsgSet.new(:friend_ids, "is invalid: %s is already friends with %s", :user, :friend) }

    ERROR_TARGETS = { :forbidden    =>  :user,
                      :pending      =>  :user,
                      :already      =>  :user }

    def initialize(*args)
      @kind = args.shift if args.first.is_a?(Symbol)
      @user = args.first
      @friend = args.last
    end

    def add_error
      msg_set = MESSAGES[@kind]
      erroring_user.errors.send(*msg_set.error_args(@user, @friend))
    end

    def get_user(sym)
      instance_variable_get(:"@#{sym}") if [:user, :friend].include?(sym)
    end

    def erroring_user
      get_user(ERROR_TARGETS[@kind])
    end

  end
end
