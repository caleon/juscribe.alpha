require File.dirname(__FILE__) + '/../test_helper'

class EntriesControllerTest < ActionController::TestCase

  def test_index
    get :index, users(:colin).to_path(true)
    assert_response :success
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:entries)
    assert_template 'index'
  end
  
  def test_index_without_user_nick
    assert_raise(ActionController::RoutingError) { get :index }
  end
  
  def test_index_with_wrong_nick
    get :index, { :user_id => users(:colin).nick.chop }
    assert_nil assigns(:entries)
    assert_flash_equal "That User entry could not be found. Please check the address.", :warning
  end
  
  def test_show
    get :show, entries(:happenings).to_path, as(:colin)
    assert_response :success
    assert_equal entries(:happenings), assigns(:entry)
  end
  
  def test_show_without_login
    get :show, entries(:happenings).to_path
    assert_response :success
    assert_equal entries(:happenings), assigns(:entry)
  end
  
  def test_show_without_login_but_private
    entries(:happenings).rule.toggle_privacy!
    get :show, entries(:happenings).to_path
    assert_redirected_to login_url
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_show_as_unauthorized
    entries(:happenings).rule.toggle_privacy!
    get :show, entries(:happenings).to_path, as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_new
    get :new, users(:colin).to_path(true), as(:colin)
    assert_response :success
    assert_not_nil assigns(:entry)
    assert assigns(:entry).new_record?
  end
  
  def test_new_with_diff_user
    get :new, users(:colin).to_path(true), as(:nana)
    assert_redirected_to new_user_entry_url(users(:nana))
  end
  
  def test_new_with_non_user
    get :new, users(:colin).to_path(true), as(12312312312312)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_create
    post :create, users(:colin).to_path(true).merge(:entry => { :user_id => users(:colin).id, :content => 'boogity-boo!' }), as(:colin)
    assert_not_nil assigns(:entry)
    assert assigns(:entry).valid?, assigns(:entry).errors.inspect
    assert_redirected_to user_entry_url(assigns(:entry).to_path)
    assert_equal "You have successfully created your Entry.", flash[:notice]
  end
  
  def test_create_with_diff_user
    post :create, users(:colin).to_path(true).merge(:entry => { :user_id => users(:keira).id, :content => 'boogity-boo!' }), as(:keira)
    assert_not_nil assigns(:entry)
    assert_redirected_to user_entry_url(assigns(:entry).to_path)
    assert_equal "You have successfully created your Entry.", flash[:notice]
  end
  
  def test_create_with_non_user
    post :create, users(:colin).to_path(true).merge(:entry => { :user_id => users(:colin).id, :content => 'boogity-boo!' }), as(123124314124)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_create_with_invalid_entry
    post :create, users(:colin).to_path(true).merge(:entry => { :user_id => users(:colin).id, :content => '' }), as(:colin)
    assert_flash_equal "There was an error creating your Entry.", :warning
    assert !assigns(:entry).valid?
  end
  
  def test_edit
    get :edit, entries(:happenings).to_path, as(:colin)
    assert_response :success
    assert_not_nil assigns(:entry)
    assert_equal entries(:happenings), assigns(:entry)
  end
  
  def test_edit_by_non_allowed
    get :edit, entries(:happenings).to_path, as(:alessandra)
    assert_redirected_to user_url(users(:alessandra))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_edit_without_login
    get :edit, entries(:happenings).to_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_update
    put :update, entries(:happenings).to_path.update(:entry => { :location => 'somewhere' }), as(:colin)
    assert_redirected_to user_entry_url(entries(:happenings).to_path)
    assert_equal "You have successfully updated #{entries(:happenings).display_name}.", flash[:notice]
  end
  
  def test_update_without_login
    put :update, entries(:happenings).to_path.update(:entry => { :location => 'somewhere' })
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_update_by_unauthorized
    put :update, entries(:happenings).to_path.update(:entry => { :location => 'somewhere' }), as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_update_with_wrong_nick
    put :update, entries(:happenings).to_path.update(:entry => { :location => 'somewhere' }, :user_id => users(:colin).to_param.chop), as(:colin)
    assert_template 'error'
    assert_flash_equal "That User entry could not be found. Please check the address.", :warning
  end
  
  def test_destroy
    @request.env["HTTP_REFERER"] = "http://www.cnn.com/"
    delete :destroy, entries(:happenings).to_path, as(:colin)
    assert_redirected_to "http://www.cnn.com/"
  end
end
