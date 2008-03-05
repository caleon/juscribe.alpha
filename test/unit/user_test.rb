require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    
  end
  
  def test_wheel_check
    user1 = User.find(:first, :conditions => ["nick = ?", 'colin'])
    assert user1.wheel?
    user2 = User.find(:first, :conditions => ["nick != ? ", 'colin'])
    assert !user2.wheel?
  end
  
  def test_editable_by_check
    assert users(:megan).editable_by?(users(:megan)), "User should be able to edit herself."
    assert users(:megan).editable_by?(users(:colin)), "User should be editable by wheel."
    assert users(:keira).editable_by?(users(:keira)), "User should be able to edit herself."
    assert !users(:keira).editable_by?(users(:alessandra)), "User should not be editable for another user."
    assert users(:keira).editable_by?(users(:colin)), "User should be editable by wheel."
    assert users(:colin).editable_by?(users(:colin)), "Wheel should be editable by wheel."
  end
  
  def test_wants_notifications_for_check
    # Stubbed
  end
  
  def test_protected_attributes
    user = User.new(:nick => 'test', :first_name => 'tester', :last_name => 'chun', :email => 'test@venturous.net', :password_salt => 'blah3124', :password_hash => '1092381098jalkj')
    assert_nil user.password_salt
    assert_nil user.password_hash
  end
  
  def test_found
    assert group = users(:colin).found(:name => 'mythers', :description => 'players of game Myth')
    assert group.is_a?(Group)
    assert group.errors.empty?
    (APP[:limits][:groups] - users(:colin).owned_groups.count).times do |i|
      assert grp = users(:colin).found(:name => "group#{i}")
      assert grp.errors.empty?
    end
    assert !users(:colin).found(:name => "groupX")
  end

  def test_creation_and_authentication
    pass_string = 'rando2m4assof8trtment'
    user = User.new(:first_name        => 'michael',
                    :last_name         => 'corleone',
                    :nick              => 'mcorleone',
                    :email             => 'mcorleone@venturous.net',
                    :birthdate         => Date.parse('1/29/1985'))
    user.nick, user.email = 'mcorleone', 'mcorleone@venturous.net'
    assert user.password = pass_string, 'Setting a password should have returned an array.'
    assert user.password_salt, 'Password salt should be set at this point.'
    assert user.password_hash, 'Password hash should be set at this point.'
    # The following not needed since test environment bypasses password validation
    #assert !user.save, 'User should not save without confirmation.'
    #user.password_confirmation = pass_string
    assert user.save, "User should properly save. #{user.errors.inspect}"
    assert User.authenticate(user.nick, pass_string), 'User should properly authenticate'
    assert !User.authenticate(user.nick, 'wrong_password'), 'Wrong password should return false'
  end
  
  def test_invalid_password_requests
    assert_raise(AbuseError) {users(:colin).password = 'whatever'}
  end
  
  ### Friendship
  
  def test_friendship_fields
    assert users(:colin)[:friend_ids].nil?
    assert !users(:colin).friend_ids.nil?
  end
  
  def test_befriending_and_unfriending
    assert users(:colin).friend_ids.empty?
    assert users(:colin).friends.empty?
    assert users(:colin).befriend(users(:keira)), "#{users(:colin).errors.inspect}"
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert users(:colin).friends.include?(users(:keira))
    assert users(:colin).friend_ids.include?(users(:keira).id)
    assert !users(:colin).friends_with?(users(:keira))
    assert !users(:colin).befriend(users(:keira))
    assert_equal 1, ActionMailer::Base.deliveries.size
    
    assert users(:keira).befriend(users(:colin)), "#{users(:keira).errors.inspect}"
    assert_equal 1, ActionMailer::Base.deliveries.size # Simply reciprocating request.
    assert users(:keira).friends.include?(users(:colin))
    assert users(:keira).friend_ids.include?(users(:colin).id)
    assert users(:colin).friends_with?(users(:keira))
    assert users(:keira).friends_with?(users(:colin))
    assert !users(:colin).befriend(users(:keira))
    assert !users(:keira).befriend(users(:colin))
    assert !users(:colin).befriend(users(:colin))
    
    assert users(:keira).unfriend(users(:colin))
    assert !users(:keira).friends.include?(users(:colin))
    assert !users(:keira).friend_ids.include?(users(:colin).id)
    assert !users(:colin).friends_with?(users(:keira))
    assert !users(:keira).friends_with?(users(:colin))
  end
  
end
