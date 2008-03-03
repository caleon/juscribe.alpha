class LimitError < StandardError; end
class FriendshipError < StandardError
  MESSAGES = { :forbidden   =>  [nil, "Friendship requests are forbidden"],
               :pending     =>  [:friend_ids, "is invalid: %s already has a friendship request with %s", :user, :friend],
               :already     =>  [:friend_ids, "is invalid: %s is already friends with %s", :user, :friend]}
               
  ERROR_TARGETS = { :forbidden    =>  :user,
                    :pending      =>  :user,
                    :already      =>  :user }
  
  attr_accessor :kind, :user, :friend

  def initialize(*args)
    @kind = args.shift if args.first.is_a?(Symbol)
    @user = args.first
    @friend = args.last
  end
  
  def add_error
    msg_set = MESSAGES[@kind]
    field = msg_set.shift
    msg_str = msg_set.shift
    msg_user_names = msg_set.map {|sym| instance_variable_get(:"@#{sym}").internal_name }
    msg = msg_str % msg_user_names
    error_args = field ? [:add, field, msg] : [:add_to_base, msg]
    erroring_user.errors.send(*error_args)
  end
  
  def erroring_user
    instance_variable_get(:"@#{ERROR_TARGETS[@kind]}")
  end
  
end
class NotifierError < StandardError; end
class LoginError < StandardError; end
class AbuseError < StandardError; end