require File.dirname(__FILE__) + '/../test_helper'

class BlogsControllerTest < ActionController::TestCase

  def test_index
    get :index, users(:colin).to_path(true)
    assert_response :success
    assert_not_nil assigns(:bloggable)
    assert_not_nil assigns(:blogs)
    assert assigns(:blogs).is_a?(Array)
  end
  
  def test_index_without_bloggable
    assert_raise(ActionController::RoutingError) { get :index }
  end
  
  def test_index_with_wrong_bloggable_user
    get :index, { :user_id => users(:colin).nick.chop }
    assert_nil assigns(:blogs)
    assert_flash_equal "That User could not be found. Please check the address.", :warning
  end
  
  def test_index_with_wrong_bloggable_group
    get :index, { :group_id => 12312312312 }
    assert_nil assigns(:blogs)
    assert_flash_equal "That Group could not be found. Please check the address.", :warning
  end
  
  def test_show
    assert blogs(:first).valid?
    get :show, blogs(:first).to_path, as(:colin)
    assert_equal users(:colin), assigns(:bloggable)
    assert_response :success
    assert_equal blogs(:first), assigns(:blog)
  end
  
  def test_show_without_bloggable
    assert_raise(ActionController::RoutingError) { get :show, { :id => blogs(:first).to_param }, as(:colin) }
  end
  
  def test_show_without_login_on_protected
    blogs(:first).rule.toggle_privacy!
    get :show, blogs(:first).to_path, as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_new
    get :new, groups(:company).to_path(true), as(:colin)
    assert_response :success
    assert_not_nil assigns(:bloggable)
    assert_equal groups(:company), assigns(:bloggable)
    assert assigns(:blog).new_record?
    assert_equal groups(:company), assigns(:blog).bloggable
  end
  
  def test_new_with_unauthorized_user
    get :new, groups(:company).to_path(true), as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  
  
  
  
  
end
