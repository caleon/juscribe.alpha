require File.dirname(__FILE__) + '/../test_helper'

class ThoughtletsControllerTest < ActionController::TestCase

  def test_index
    get :index, users(:colin).to_path(true)
    assert_response :success
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:thoughtlets)
    assert_template 'index'
  end
  
  def test_index_without_user_nick
    assert_raise(ActionController::RoutingError) { get :index }
  end
  
  def test_index_with_wrong_nick
    get :index, { :user_id => users(:colin).nick.chop }
    assert_nil assigns(:thoughtlets)
    assert_flash_equal "That User could not be found. Please check the address.", :warning
  end
  
  def test_show
    get :show, thoughtlets(:happenings).to_path, as(:colin)
    assert_response :success
    assert_equal thoughtlets(:happenings), assigns(:thoughtlet)
  end
  
  def test_show_without_login
    get :show, thoughtlets(:happenings).to_path
    assert_response :success
    assert_equal thoughtlets(:happenings), assigns(:thoughtlet)
  end
  
  def test_show_without_login_but_private
    thoughtlets(:happenings).rule.toggle_privacy!
    get :show, thoughtlets(:happenings).to_path
    assert_redirected_to login_url
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_show_as_unauthorized
    thoughtlets(:happenings).rule.toggle_privacy!
    get :show, thoughtlets(:happenings).to_path, as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_new
    get :new, users(:colin).to_path(true), as(:colin)
    assert_response :success
    assert_not_nil assigns(:thoughtlet)
    assert assigns(:thoughtlet).new_record?
  end
  
  def test_new_with_diff_user
    get :new, users(:colin).to_path(true), as(:nana)
    assert_redirected_to new_user_thoughtlet_url(users(:nana))
  end
  
  def test_new_with_non_user
    get :new, users(:colin).to_path(true), as(12312312312312)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_create
    post :create, users(:colin).to_path(true).merge(:thoughtlet => { :user_id => users(:colin).id, :content => 'boogity-boo!' }), as(:colin)
    assert_not_nil assigns(:thoughtlet), users(:colin).to_path(true).inspect
    assert assigns(:thoughtlet).valid?, assigns(:thoughtlet).errors.inspect
    assert_redirected_to user_thoughtlet_url(assigns(:thoughtlet).to_path)
    assert_equal "You have successfully created your Thoughtlet.", flash[:notice]
  end
  
  def test_create_with_diff_user
    post :create, users(:colin).to_path(true).merge(:thoughtlet => { :user_id => users(:keira).id, :content => 'boogity-boo!' }), as(:keira)
    assert_not_nil assigns(:thoughtlet)
    assert_redirected_to user_thoughtlet_url(assigns(:thoughtlet).to_path)
    assert_equal "You have successfully created your Thoughtlet.", flash[:notice]
  end
  
  def test_create_with_non_user
    post :create, users(:colin).to_path(true).merge(:thoughtlet => { :user_id => users(:colin).id, :content => 'boogity-boo!' }), as(123124314124)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_create_with_invalid_entry
    post :create, users(:colin).to_path(true).merge(:thoughtlet => { :user_id => users(:colin).id, :content => '' }), as(:colin)
    assert_flash_equal "There was an error creating your Thoughtlet.", :warning
    assert !assigns(:thoughtlet).valid?
  end
  
  def test_edit
    get :edit, thoughtlets(:happenings).to_path, as(:colin)
    assert_response :success
    assert_not_nil assigns(:thoughtlet)
    assert_equal thoughtlets(:happenings), assigns(:thoughtlet)
  end
  
  def test_edit_by_non_allowed
    get :edit, thoughtlets(:happenings).to_path, as(:alessandra)
    assert_redirected_to user_url(users(:alessandra))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_edit_without_login
    get :edit, thoughtlets(:happenings).to_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_update
    put :update, thoughtlets(:happenings).to_path.update(:thoughtlet => { :location => 'somewhere' }), as(:colin)
    assert_redirected_to user_thoughtlet_url(thoughtlets(:happenings).to_path)
    assert_equal "You have successfully updated #{flash_name_for(thoughtlets(:happenings))}.", flash[:notice]
  end
  
  def test_update_without_login
    put :update, thoughtlets(:happenings).to_path.update(:thoughtlet => { :location => 'somewhere' })
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_update_by_unauthorized
    put :update, thoughtlets(:happenings).to_path.update(:thoughtlet => { :location => 'somewhere' }), as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_update_with_wrong_nick
    put :update, thoughtlets(:happenings).to_path.update(:thoughtlet => { :location => 'somewhere' }, :user_id => users(:colin).to_param.chop), as(:colin)
    assert_template 'error'
    assert_flash_equal "That User could not be found. Please check the address.", :warning
  end
  
  def test_destroy
    @request.env["HTTP_REFERER"] = "http://www.cnn.com/"
    delete :destroy, thoughtlets(:happenings).to_path, as(:colin)
    assert_redirected_to "http://www.cnn.com/"
  end
end
