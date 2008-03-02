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
  end
  
  def test_join
    assert groups(:friends).join(users(:megan))
    assert !groups(:friends).join(users(:megan))
    assert_equal Membership.find_by_group_id_and_user_id('friends'.hash.abs, 'megan'.hash.abs),
                 groups(:friends).membership_for(users(:megan))
    (APP[:limits][:memberships] - users(:megan).groups.count).times do |i|
      grp = Group.create(:name => "group#{i}")
      grp.join(users(:megan))
    end
    group = Group.create(:name => 'groupX')
    assert !group.join(users(:megan))
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
