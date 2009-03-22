require File.dirname(__FILE__) + '/../test_helper'

class GalleriesControllerTest < ActionController::TestCase

  def test_index
    get :index, users(:colin).to_path(true)
    assert_response :success
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:galleries)
    assert assigns(:galleries).is_a?(Array)
  end
  
  def test_index_without_user_nick
    assert_raise(ActionController::RoutingError) { get :index }
  end
  
  def test_index_with_wrong_nick
    get :index, { :user_id => users(:colin).nick.chop }
    assert_nil assigns(:galleries)
    assert_flash_equal "That User could not be found. Please check the address.", :warning
  end
  
  def test_show
    get :show, galleries(:trip).to_path, as(:colin)
    assert_response :success
    assert_equal galleries(:trip), assigns(:gallery)
  end
  
  def test_show_without_user_nick
    assert_raise(ActionController::RoutingError) { get :show, { :id => galleries(:trip).id }, as(:colin) }
  end
  
  def test_show_without_login
    get :show, galleries(:trip).to_path
    assert galleries(:trip).public?
    assert galleries(:trip).rule.public?
    assert galleries(:trip).rule.accessible_by?(nil)
    assert galleries(:trip).accessible_by?(nil)
    assert_response :success
    assert_template 'show'
  end
  
  def test_show_without_login_on_protected
    galleries(:trip).rule.toggle_privacy!
    get :show, galleries(:trip).to_path, as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_new
    get :new, users(:colin).to_path(true), as(:colin)
    assert_response :success
    assert_not_nil assigns(:gallery)
  end
  
  def test_new_with_diff_user
    get :new, users(:colin).to_path(true), as(:nana)
    assert_redirected_to new_user_gallery_url(users(:nana))
  end
  
  def test_new_with_non_user
    get :new, users(:colin).to_path(true), as(123123123)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_create
    post :create, users(:colin).to_path(true).merge(:gallery => { :name => 'test', :description => 'blah blah', :user_id => users(:colin).id} ), as(:colin)
    assert_not_nil assigns(:gallery)
    assert_equal users(:colin), assigns(:gallery).user
    assert_redirected_to user_gallery_url(assigns(:gallery).to_path)
    assert_equal "You have successfully created your gallery.", flash[:notice]
  end
  
  def test_create_without_user_id_in_params
    post :create, users(:colin).to_path(true).merge(:gallery => { :name => 'test', :description => 'blah blah' }), as(:colin)
    assert_not_nil assigns(:gallery)
    assert_equal users(:colin), assigns(:gallery).user
    assert_redirected_to user_gallery_url(assigns(:gallery).to_path)
    assert_equal "You have successfully created your gallery.", flash[:notice]
  end
  
  def test_create_with_diff_user
    post :create, users(:colin).to_path(true).merge(:gallery => { :name => 'test', :description => 'blah blah' }), as(:keira)
    assert_not_nil assigns(:gallery)
    assert_equal users(:keira), assigns(:gallery).user
    assert_redirected_to user_gallery_url(assigns(:gallery).to_path)
    assert_equal "You have successfully created your gallery.", flash[:notice]
  end
  
  def test_create_with_non_user
    post :create, users(:colin).to_path(true).merge(:gallery => { :name => 'test', :description => 'blah blah' }), as(123123)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  # No validations on input fields.
  
  def test_edit
    get :edit, galleries(:trip).to_path, as(:colin)
    assert_equal users(:colin), galleries(:trip).user
    assert galleries(:trip).accessible_by?(users(:colin))
    assert galleries(:trip).editable_by?(users(:colin))
    assert_response :success
    assert_not_nil assigns(:gallery)
    assert_equal galleries(:trip), assigns(:gallery)
  end
  
  def test_edit_by_non_allowed
    get :edit, galleries(:trip).to_path, as(:alessandra)
    assert_redirected_to user_url(users(:alessandra))
    assert_equal "You are not authorized for that action.", flash[:warning]
    # TODO: this means only users can edit stuff like groups and events... FIX.
  end
  
  def test_edit_without_login
    get :edit, galleries(:trip).to_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_update
    put :update, galleries(:trip).to_path.merge(:gallery => { :name => 'blah' }), as(:colin)
    assert_redirected_to user_gallery_url(galleries(:trip).to_path)
    assert_equal "You have successfully updated #{flash_name_for(galleries(:trip))}.", flash[:notice]
  end
  
  def test_update_without_login
    put :update, galleries(:trip).to_path.merge(:gallery => { :name => 'blah' })
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_update_by_unauthorized
    put :update, galleries(:trip).to_path.merge(:gallery => { :name => 'blah' }), as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_update_with_wrong_nick
    put :update, galleries(:trip).to_path.merge(:user_id => users(:colin).nick.chop, :gallery => { :name => 'blah' }), as(:colin)
    assert_template 'error'
    assert_flash_equal "That User could not be found. Please check the address.", :warning
  end
  
  def test_destroy
    @request.env["HTTP_REFERER"] = "http://www.cnn.com/"
    delete :destroy, galleries(:trip).to_path, as(:colin)
    assert_redirected_to "http://www.cnn.com/"
  end
  
  def test_destroy_by_unlogged_in
    delete :destroy, galleries(:trip).to_path
    assert_redirected_to login_url
  end
  
  def test_destroy_by_unauthorized
    delete :destroy, galleries(:trip).to_path, as(:keira)
    assert_redirected_to user_url(users(:keira))
  end
end
