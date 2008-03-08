require File.dirname(__FILE__) + '/../test_helper'

class MembershipTest < ActiveSupport::TestCase
  
  def test_validations
    orig_count = Membership.count
    mem = Membership.new
    assert !mem.valid?
    mem.user = users(:keira)
    assert !mem.valid?
    mem.group = groups(:company)
    assert mem.valid?
    assert mem.save, mem.errors.inspect
    assert_equal orig_count + 1, Membership.count
    # TODO: Need to create_index on db to do a double safeguard against this.
    mem2 = Membership.new(:user => mem.user, :group => mem.group)
    assert !mem2.valid?
    assert_equal orig_count + 1, Membership.count
    assert_equal [mem.user_id, mem.group_id], [mem2.user_id, mem2.group_id]
    assert !mem2.valid?, [[mem.user_id, mem.group_id], [mem2.user_id, mem2.group_id]].inspect
    assert !mem2.errors.on(:user_id).blank?
  end

  def test_rank
    mem = groups(:friends).membership_for(users(:keira))
    assert_nil mem[:rank]
    assert_equal 0, mem.rank
    assert groups(:friends).assign_rank(users(:keira), 7)
    assert_not_nil mem.reload[:rank]
    assert_equal 7, mem.rank
  end
end
