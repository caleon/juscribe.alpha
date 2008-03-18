require File.dirname(__FILE__) + '/../test_helper'

class PermissionsControllerTest < ActionController::TestCase

  def test_index
    get :index, {}, as(:colin)
    assert_not_nil assigns(:permission_rules)
    assert_equal users(:colin).permission_rules, assigns(:permission_rules)
    assert_template 'index'
  end
  
  def test_index_without_user
    get :index
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_show
    get :show, permission_rules(:colin).to_path, as(:colin)
    assert_response :success
    assert_equal permission_rules(:colin), assigns(:permission_rule)
  end
  
  def test_show2
    get :show, permission_rules(:blog).to_path, as(:colin)
    assert_response :success
    assert_equal permission_rules(:blog), assigns(:permission_rule)
  end
  
  def test_show_without_user
    get :show, permission_rules(:blog).to_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_show_with_unauthorized_user
    get :show, permission_rules(:blog).to_path, as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_new
    get :new, {}, as(:colin)
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:permission_rule)
    assert assigns(:permission_rule).new_record?
  end
  
  def test_new_without_user
    get :new
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_create
    post :create, { :permission_rule => { :name => 'just for friends', :description => 'only my friends can see.' } }, as(:colin)
    assert_not_nil assigns(:permission_rule)
    assert assigns(:permission_rule).valid?
    assert_redirected_to permission_url(assigns(:permission_rule))
    assert_equal "You have successfully created a permission rule.", flash[:notice]
  end
  
  def test_create_without_user
    post :create, { :permission_rule => { :name => 'just for friends', :description => 'only my friends can see.' } }
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_edit
    get :edit, permission_rules(:blog).to_path, as(:colin)
    assert_response :success
    assert_equal permission_rules(:blog), assigns(:permission_rule)
    assert_template 'edit'
  end
  
  def test_edit_without_user
    get :edit, permission_rules(:blog).to_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_edit_with_wrong_user
    get :edit, permission_rules(:blog).to_path, as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_update
    put :update, permission_rules(:blog).to_path.merge(:permission_rule => { :name => 'BEST friends' }), as(:colin)
    assert_redirected_to permission_url(permission_rules(:blog))
    assert_equal "You have successfully updated #{permission_rules(:blog).display_name}.", flash[:notice]
  end
  
  def test_update_without_user
    put :update, permission_rules(:blog).to_path.merge(:permission_rule => { :name => 'BEST friends' })
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_update_with_wrong_user
    put :update, permission_rules(:blog).to_path.merge(:permission_rule => { :name => 'BEST friends' }), as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_destroy
    delete :destroy, permission_rules(:blog).to_path, as(:colin)
    assert_redirected_to permissions_url
    assert_equal "You have deleted the permission rule #{permission_rules(:blog).display_name}.", flash[:notice]
  end
  
  def test_destroy_without_user
    delete :destroy, permission_rules(:blog).to_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_destroy_with_wrong_user
    delete :destroy, permission_rules(:blog).to_path, as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
end
