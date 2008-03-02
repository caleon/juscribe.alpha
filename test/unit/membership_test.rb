require File.dirname(__FILE__) + '/../test_helper'

class MembershipTest < ActiveSupport::TestCase

  def test_rank
    mem = groups(:friends).membership_for(users(:keira))
    assert_nil mem[:rank]
    assert_equal 0, mem.rank
    assert groups(:friends).assign_rank(users(:keira), 7)
    assert_not_nil mem.reload[:rank]
    assert_equal 7, mem.rank
  end
end
