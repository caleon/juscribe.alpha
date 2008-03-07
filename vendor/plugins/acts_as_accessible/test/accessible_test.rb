require File.dirname(__FILE__) + "/../../../../test/test_helper"

class Mixin < ActiveRecord::Base
end

class AccessibleMixin < Mixin
  acts_as_accessible
  belongs_to :user

  def self.table_name() "articles" end # CHANGED: set this to an existing table
    # ALSO this test requires a Group model associated to User
end

class AccessibleMixinSub1 < AccessibleMixin
end

class AccessibleMixinSub2 < AccessibleMixin
end


class AccessibleTest < Test::Unit::TestCase

  def setup # CHANGED: these can be set to User.create(..)
    @user = users(:keira)
    @stranger = users(:megan)
    @colin = users(:colin)
  end
    
  def test_rule_generation
    assert_equal 0, PermissionRule.count
    acc1 = AccessibleMixin.create(:user => @user)
    assert_nil acc1.permission
    assert acc1.public?
    assert_equal 1, PermissionRule.count
    assert_not_nil p = acc1.permission
    assert rule1 = p.permission_rule
    assert !acc1.private?
    assert !acc1.protected?
    assert_equal rule1, acc1.rule
    
    assert rule2 = acc1.create_rule(:user_id => @user.id)
    assert_not_nil acc1.rule
    assert_equal rule2, acc1.rule
    assert_not_equal rule1, acc1.rule
    assert acc1.rule = rule1
    assert_equal rule1, acc1.rule
    assert acc1.public? && !acc1.private? && !acc1.protected?
  end
  
  def test_editable_check
    acc1 = AccessibleMixin.create
    assert !acc1.editable_by?(@user)
    acc1.user = @user
    acc1.save
    assert acc1.editable_by?(@user)
    assert !acc1.editable_by?(@stranger)
  end
  
  def test_whitelist_blacklist
    acc1 = AccessibleMixin.create(:user => @colin)
    rule1 = acc1.create_rule(:user => @user)
    rule1.deny!(:user, @user)
    assert rule1.protected?
    assert_equal rule1, acc1.rule
    assert !rule1.accessible_by?(@user)
    assert !acc1.accessible_by?(@user)
    rule1.allow!(:user, @user)
    # Because #allow! doesn't remove the user from denied list:
    assert !rule1.accessible_by?(@user)
    assert !acc1.accessible_by?(@user)
    
    rule1.whitelist!(:user, @user)
    assert rule1.public? # This is only because there aren't other users on lists
    assert rule1.allowed[:user].include?(@user.id)
    assert_equal rule1, acc1.rule
    assert_equal @colin, acc1.user
    assert_equal rule1.allowed, acc1.reload.rule.allowed # Hm, hate that I have to reload...
    assert rule1.accessible_by?(@user)
    assert acc1.rule.accessible_by?(@user)
    assert acc1.accessible_by?(@user)
    assert_equal rule1, acc1.rule
    assert acc1.accessible_by?(@user)
    assert !rule1.denied[:user].include?(@user.id)
    
    rule1.blacklist!(:user, @user)
    #flunk "#{acc1.rule.denied.inspect}"
    assert rule1.denied[:user].include?(@user.id)
    assert !acc1.reload.accessible_by?(@user) # Another reload needed
    assert !rule1.allowed[:user].include?(@user.id)
  end
  
  def test_accessible_check
    acc1 = AccessibleMixin.create(:user => @user)
    assert acc1.accessible_by?(@user)
    acc1.user = @user
    acc1.save
    
    # Public
    assert acc1.accessible_by?(@user)
    assert acc1.accessible_by?(@stranger)
    assert rule1 = acc1.create_rule(:user => @user)
    assert acc1.accessible_by?(@user)
    assert acc1.accessible_by?(@stranger)
    assert acc1.public?
    assert acc1.rule.public?
    
    # Private
    rule1 = acc1.rule
    assert !rule1.private?
    assert !acc1.private?
    rule1.toggle_privacy!
    assert rule1.private?
    assert acc1.private?
    assert acc1.accessible_by?(@user)
    assert !acc1.accessible_by?(@stranger)
    assert acc1.accessible_by?(@colin)
    rule1.allow!(:user, @stranger)
    assert_equal [@stranger.id], rule1.allowed[:user]
    assert acc1.accessible_by?(@stranger)
    rule1.undo_allow!(:user, @stranger)
    assert rule1.allowed[:user].empty?
    assert !acc1.accessible_by?(@stranger)
    group = Group.create(:name => 'makito', :user => @stranger)
    mem = group.memberships.create
    @stranger.memberships << mem
    assert group.users.include?(@stranger)
    assert_equal group, mem.group
    assert_equal @stranger, mem.user
    assert @stranger.reload.groups.include?(group)
    # Currently inaccessible by user.
    rule1.allow!(:group, group)
    assert acc1.accessible_by?(@stranger)
    
    # Protected
    rule1.toggle_privacy!
    assert rule1.public?
    rule1.deny!(:user, @stranger)
    assert rule1.protected?
    assert rule1.accessible_by?(@user)
    assert acc1.accessible_by?(@user)
    assert rule1.denied[:user].include?(@stranger.id)
    assert !rule1.reload.accessible_by?(@stranger)
    assert !acc1.accessible_by?(@stranger)
    assert rule1.accessible_by?(@colin)
    assert acc1.accessible_by?(@colin)
    # stranger still in group
    rule1.undo_deny!(:user, @stranger)
    assert acc1.accessible_by?(@stranger)
    rule1.deny!(:group, group)
    assert !acc1.accessible_by?(@stranger)
  end
  
  def test_reassignments
    acc1 = AccessibleMixin.create(:user => @user)
    acc2 = AccessibleMixin.create(:user => @user)
    rule1 = acc1.create_rule(:user => @user)
    rule2 = rule1.duplicate
    assert_equal 0, rule2.permissions.size
    rule1.apply_to!(acc2)
    assert_equal rule1, acc1.rule
    assert_equal rule1, acc2.rule
    acc3 = AccessibleMixin.create(:user => @user)
    acc4 = AccessibleMixin.create(:user => @user)
    acc3.rule = rule1
    acc4.rule = rule1
    assert_equal 4, rule1.permissions.count
    assert_equal 0, rule2.permissions.count
    rule1.reassign_all_to!(rule2)
    assert_equal 0, rule1.reload.permissions.count
    assert_equal 4, rule2.reload.permissions.count
    assert_equal PermissionRule.find(rule2.id), AccessibleMixin.find(acc1).rule
  
    rule2.reassign_all_to!(rule1, :delete => true)
    assert_equal 4, rule1.permissions.count
    assert_equal rule1, acc1.rule
    assert_equal rule1, acc2.rule
    assert_equal rule1, acc3.rule
    assert_equal rule1, acc4.rule
    assert_raise(ActiveRecord::RecordNotFound) { PermissionRule.find(rule2.id) }
  end

end
