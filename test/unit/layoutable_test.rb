require File.dirname(__FILE__) + '/../test_helper'

class LayoutableTest < ActiveSupport::TestCase

  def test_layout
#    assert_equal 'default', users(:colin).layout
#    assert_equal 'users/layouts/default/default', users(:colin).layout_file
#    
#    users(:colin)[:layout] = 'msm'
#    assert_equal 'msm', users(:colin).layout
#    assert_equal 'users/layouts/msm/', users(:colin).layout_path
#    assert_equal 'users/layouts/msm/msm', users(:colin).layout_file
#    assert_equal 'users/layouts/msm/articles', users(:colin).layout_file(:articles)
  end
  
  def test_skin
    # FIXME: Functionality being worked on right now. (3/20/08)
    #assert_equal 'default', users(:colin).skin
    #assert_equal 'users/default', users(:colin).skin_file
    #
    #users(:colin)[:skin] = 'msm'
    #assert_equal 'msm', users(:colin).skin
    #assert_equal 'users/msm', users(:colin).skin_file
  end
  
  def test_setting_layoutable_chain
    assert_not_nil Article.layoutable_association
  end
end