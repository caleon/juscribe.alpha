class LimitError < StandardError; end
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
    instance_variable_get(:"@#{sym}")
  end
  
  def erroring_user
    get_user(ERROR_TARGETS[@kind])
  end
  
end
class NotifierError < StandardError; end
class LoginError < StandardError; end
class AbuseError < StandardError; end