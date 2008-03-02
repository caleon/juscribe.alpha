class LimitError < StandardError; end
class FriendshipError < StandardError
  def to_s
    ""
  end
end
class NotifierError < StandardError; end
class LoginError < StandardError; end
class AbuseError < StandardError; end