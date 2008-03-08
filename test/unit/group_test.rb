require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < ActiveSupport::TestCase

  def test_editable_by_check
    assert groups(:friends).editable_by?(users(:colin))
    assert !groups(:friends).editable_by?(users(:alessandra))
    assert !groups(:friends).editable_by?(users(:keira))
    assert groups(:friends).membership_for(users(:keira))
    assert_raise(ActiveRecord::RecordNotFound) { groups(:friends).membership_for(users(:alessandra)) }
    assert_equal 0, groups(:friends).rank_for(users(:keira))
    assert groups(:friends).assign_rank(users(:keira), Membership::ADMIN_RANK)
    assert groups(:friends).editable_by?(users(:keira))
  end
  
  def test_accessible_by_check
    assert groups(:friends).accessible_by?(users(:colin))
    assert groups(:friends).accessible_by?(users(:megan))
    rule = groups(:friends).rule
    assert rule.public?
    rule.toggle_privacy!
    assert rule.private?
    assert groups(:friends).accessible_by?(users(:colin))
    assert !groups(:friends).accessible_by?(users(:megan))
    rule.whitelist!(:user, users(:megan))
    assert groups(:friends).accessible_by?(users(:megan))
  end

  def test_membership_for
    assert_equal memberships(:colin_friends), groups(:friends).membership_for(users(:colin))
    assert_raise(ActiveRecord::RecordNotFound) { groups(:friends).membership_for(users(:alessandra)) }
  end
  
  def test_has_member_check
    assert groups(:friends).has_member?(users(:colin))
    assert !groups(:friends).has_member?(users(:nana))
  end
  
  def test_rank_for
    assert_equal memberships(:colin_friends).rank, groups(:friends).rank_for(users(:colin))
    assert_raise(ActiveRecord::RecordNotFound) { groups(:friends).membership_for(users(:alessandra)) }
  end
  
  def test_assign_rank
    assert_not_equal 3, groups(:friends).rank_for(users(:keira))
    assert groups(:friends).assign_rank(users(:keira), 3)
    assert_equal 3, groups(:friends).rank_for(users(:keira))
    assert !groups(:friends).assign_rank(users(:keira), -5)
    assert !groups(:friends).assign_rank(users(:megan), 5)
    assert_not_nil groups(:friends).errors
  end
  
  def test_join
    assert groups(:friends).join(users(:megan))
    assert !groups(:friends).join(users(:megan))
    assert_equal Membership.find_by_group_id_and_user_id('friends'.hash.abs, 'megan'.hash.abs),
                 groups(:friends).membership_for(users(:megan))
    ##########
    mem_count = users(:colin).groups.count
    mem_limit = APP[:limits][:memberships]
    (mem_limit - mem_count).times do |i|
      usr = User.new(:first_name => 'test', :last_name => 'user', :birthdate => Date.parse('1/29/1985'))
      usr.nick, usr.email = "testuser#{i}", "testuser#{i}@venturous.net"
      usr.save
      grp = Group.create(:name => "testgroup#{i}", :user => usr) 
      grp.join(users(:colin))
    end
    group = Group.create(:name => "overthelimit", :user => users(:keira))
    assert !group.join(users(:colin))
    assert_equal 1, group.errors.size, group.errors.inspect
  end
  
  def test_join_with_options
    assert groups(:friends).join(users(:nana), :rank => 7, :title => 'the Girlfriend')
    assert !groups(:friends).join(users(:nana))
    assert_equal mem = Membership.find_by_group_id_and_user_id('friends'.hash.abs, 'nana'.hash.abs),
                 groups(:friends).membership_for(users(:nana))
    assert_equal 7, mem.rank
    assert_equal 'the Girlfriend', mem.title
  end
  
  def test_kick
    assert groups(:friends).has_member?(users(:keira))
    assert groups(:friends).kick(users(:keira))
    assert !groups(:friends).has_member?(users(:keira))
    assert !ActionMailer::Base.deliveries.empty?
  end
  
  def test_disband
    orig_deliveries_count = ActionMailer::Base.deliveries.size
    members_count = groups(:friends).users.count
    orig_membership_count = Membership.count
    groups(:friends).disband!
    assert_equal orig_membership_count - members_count, Membership.count
    assert_raise(ActiveRecord::RecordNotFound) { Group.find('friends'.hash.abs) }
    assert_equal orig_deliveries_count + 1, ActionMailer::Base.deliveries.size
  end
end
