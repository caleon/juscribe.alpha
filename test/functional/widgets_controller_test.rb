require File.dirname(__FILE__) + '/../test_helper'

class WidgetsControllerTest < ActionController::TestCase

  def test_index
    get :index, users(:colin).to_path(true)
    assert_redirected_to login_url
  end

  def test_index_as_user
    get :index, users(:colin).to_path(true), as(:colin)
    assert_response :success
    assert_equal users(:colin), assigns(:user)
    assert_not_nil assigns(:widgets)
    assert assigns(:widgets).is_a?(Array)
    assert_template 'index'
  end
  
  def test_index_without_user_nick
    assert_raise(ActionController::RoutingError) { get :index }
  end
  
  def test_index_with_wrong_nick
    get :index, { :user_id => users(:colin).nick.chop }
    assert_nil assigns(:widgets)
    assert_flash_equal "Unable to find the user specified. Please check the address.", :warning
  end
  
  def test_index_with_diff_user_but_private
    users(:colin).create_rule.toggle_privacy!
    assert users(:colin).private?
    assert !users(:colin).accessible_by?(users(:nana))
    get :index, users(:colin).to_path(true), as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
    
  def test_index_with_no_user_but_private
    users(:colin).create_rule.toggle_privacy!
    assert users(:colin).private?
    get :index, users(:colin).to_path(true)
    assert_redirected_to login_url
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
    
  def test_show
    get :show, widgets(:colin_clip).to_path(:user)
    assert_response :success
    assert_equal widgets(:colin_clip), assigns(:widget)
  end
  
  def test_show_with_login
    get :show, widgets(:colin_clip).to_path(:user), as(:colin)
    assert_response :success
    assert_equal widgets(:colin_clip), assigns(:widget)
  end
  
  def test_show_with_diff_login
    get :show, widgets(:colin_clip).to_path(:user), as(:keira)
    assert_response :success
    assert_equal widgets(:colin_clip), assigns(:widget)
  end
  
  def test_show_without_login_but_private
    users(:colin).create_rule.toggle_privacy!
    assert users(:colin).private?
    get :show, widgets(:colin_clip).to_path(:user)
    assert_redirected_to login_url
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_show_with_diff_login_but_private
    users(:colin).create_rule.toggle_privacy!
    assert users(:colin).private?
    get :show, widgets(:colin_clip).to_path(:user), as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_new
    # Does not exist.
  end
  
  def test_create
    # Does not exist.
  end
  
  def test_edit
    get :edit, widgets(:colin_clip).to_path(:user), as(:colin)
    assert_response :success
    assert_not_nil assigns(:widget)
    assert_equal widgets(:colin_clip), assigns(:widget)
  end
  
  def test_edit_by_non_allowed
    get :edit, widgets(:colin_clip).to_path(:user), as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_edit_without_login
    get :edit, widgets(:colin_clip).to_path(:user)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_update
    put :update, widgets(:colin_clip).to_path(:user).update(:widget => { :name => 'blah' }), as(:colin)
    assert_redirected_to user_widgets_url(users(:colin))
    assert_equal "You have successfully updated #{flash_name_for(widgets(:colin_clip))}.", flash[:notice]
  end
  
  def test_update_without_login
    put :update, widgets(:colin_clip).to_path(:user).update(:widget => { :name => 'blah' })
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_update_by_unauthorized
    put :update, widgets(:colin_clip).to_path(:user).update(:widget => { :name => 'blah' }), as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_update_with_wrong_nick
    put :update, widgets(:colin_clip).to_path(:user).update(:widget => { :name => 'blah' }, :user_id => users(:colin).nick.chop), as(:colin)
    assert_template 'error'
    assert_flash_equal "That User could not be found. Please check the address.", :warning
  end
  
  def test_place
    put :place, widgets(:colin_clip).to_path(:user).merge(:widget => { :position => 4 }), as(:colin)
    assert_redirected_to user_widgets_url(users(:colin))
    assert_equal "You have placed #{flash_name_for(widgets(:colin_clip))}.", flash[:notice]
  end
  
  def test_place_without_params
    put :place, widgets(:colin_clip).to_path(:user), as(:colin)
    assert_template 'error'
    assert_flash_equal "Invalid request. Please try again.", :warning
  end
  
  def test_unplace
    put :unplace, widgets(:colin_clip).to_path(:user), as(:colin)
    assert_redirected_to user_widgets_url(users(:colin))
    assert_equal "You have unplaced #{flash_name_for(widgets(:colin_clip))}.", flash[:notice]
  end
  
  def test_destroy
    delete :destroy, widgets(:colin_clip).to_path(:user), as(:colin)
    assert_redirected_to user_url(users(:colin))
    assert_equal "You have deleted #{flash_name_for(widgets(:colin_clip))}.", flash[:notice]
  end
  
  def test_destroy_by_random_user
    delete :destroy, widgets(:colin_clip).to_path(:user), as(:alessandra)
    assert_redirected_to user_url(users(:alessandra))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_destroy_by_owner_of_widgetable
    articles(:blog).publish!
    assert_equal users(:colin), articles(:blog).user
    assert_equal users(:nana), widgets(:article_clip).user
    assert_equal articles(:blog), widgets(:article_clip).widgetable
    assert widgets(:article_clip).accessible_by?(users(:nana))
    assert widgets(:article_clip).accessible_by?(users(:colin))
    assert articles(:blog).public?
    articles(:blog).create_rule.toggle_privacy!
    assert widgets(:article_clip).reload.accessible_by?(users(:colin))
    assert !widgets(:article_clip).reload.accessible_by?(users(:keira))
    
    delete :destroy, widgets(:article_clip).to_path(:user), as(:colin)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You have deleted #{flash_name_for(widgets(:article_clip))}.", flash[:notice]
  end
end
