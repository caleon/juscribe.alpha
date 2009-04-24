class Commenter
  def initialize(attrs={})
    raise ArgumentError unless attrs[:nick]
    @nick = attrs[:nick]
    @email = attrs[:email]
  end
  
  def full_name
    @nick
  end
  
  def first_name
    @nick
  end
  
  def email
    @email
  end
  
  def email_address
    "#{@nick}<#{@email}>"
  end
  
  def notify_for?(arg)
    false
  end
end