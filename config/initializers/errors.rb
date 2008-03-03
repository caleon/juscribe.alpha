class LimitError < StandardError; end
class FriendshipError < StandardError
  class MsgSet
    def initialize(field, msg, *vars)
      @arr = [field, msg, *vars]
    end

    def field; @arr[0]; end
    def msg_str; @arr[1]; end
    def users; @arr[2..-1]; end
  end
  
  MESSAGES = { :forbidden   =>  MsgSet.new(nil, "Friendship requests are forbidden"),
               :pending     =>  MsgSet.new(:friend_ids, "is invalid: %s already has a friendship request with %s", :user, :friend),
               :already     =>  MsgSet.new(:friend_ids, "is invalid: %s is already friends with %s", :user, :friend) }
               
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
    msg = msg_set.msg_str % msg_set.users.map {|sym| get_user(sym) }
    error_args = msg_set.field ? [:add, msg_set.field, msg] : [:add_to_base, msg]
    erroring_user.errors.send(*error_args)
  end
  
  def get_user(sym)
    instance_variable_get(:"@#{sym}")
  end
  
  def erroring_user
    get_user(ERROR_TARGETS[@kind])
  end
  
end
class NotifierError < StandardError; end
class LoginError < StandardError; end
class AbuseError < StandardError; end