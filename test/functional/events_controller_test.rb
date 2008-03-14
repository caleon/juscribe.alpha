require File.dirname(__FILE__) + '/../test_helper'

class EventsControllerTest < ActionController::TestCase

  def test_index
    get :index, users(:colin).to_path(true)
    assert_response :success
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:events)
    assert_template 'index'
  end
  
  def test_index_without_user_nick
    assert_raise(ActionController::RoutingError) { get :index }
  end
  
  def test_index_with_wrong_nick
    get :index, { :user_id => users(:colin).nick.chop }
    assert_nil assigns(:events)
    assert_flash_equal "That User entry could not be found. Please check the address.", :warning
  end
  
  def test_show
    get :show, events(:birthday).to_path, as(:colin)
    assert_response :success
    assert_equal events(:birthday), assigns(:event)
  end
  
  def test_show_without_user_nick
    assert_raise(ActionController::RoutingError) { get :show, { :id => events(:birthday).id }, as(:colin) }
  end
  
  def test_show_without_login
    get :show, events(:birthday).to_path
    assert events(:birthday).public?
    assert events(:birthday).rule.public?
    assert events(:birthday).rule.accessible_by?(nil) # returns false
    assert events(:birthday).accessible_by?(nil) # returns false
    assert_response :success
  end
  
  def test_show_without_login_on_protected
    events(:birthday).rule.toggle_privacy!
    get :show, events(:birthday).to_path, as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_new
    get :new, users(:colin).to_path(true), as(:colin)
    assert_response :success
    assert_not_nil assigns(:event)
  end
  
  def test_new_with_diff_user
    get :new, { :user_id => users(:colin).nick }, as(:nana)
    assert_redirected_to new_user_event_url(users(:nana))
  end
  
  def test_new_with_non_user
    get :new, { :user_id => users(:colin).nick }, { :id => 12312312312 }
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_create
    post :create, { :user_id => users(:colin).nick, :event => { :name => 'brouhaha', :content => 'hahaha.brouhahah.', :user_id => users(:colin).id } }, as(:colin)
    assert_not_nil assigns(:event)
    assert_redirected_to user_event_url(assigns(:event).to_path)
    assert_equal "You have successfully created your event.", flash[:notice]
  end
  
  def test_create_with_diff_user
    post :create, { :user_id => users(:colin).nick, :event => { :name => 'brouhaha', :content => 'hahaha.brouhahah.', :user_id => users(:keira).id } }, as(:keira)
    assert_not_nil assigns(:event)
    assert_redirected_to user_event_url(assigns(:event).to_path)
    assert_equal "You have successfully created your event.", flash[:notice]
  end
  
  def test_create_with_non_user
    post :create, { :user_id => users(:colin).nick, :event => { :name => 'brouhaha', :content => 'hahaha.brouhahah.', :user_id => users(:colin).id } }, as(1213231231)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_create_with_invalid_entry
    post :create, { :user_id => users(:colin).nick, :event => { :name => '', :content => 'hahaha.brouhahah.', :user_id => users(:colin).id } }, as(:colin)
    assert_flash_equal "There was an error creating your event.", :warning
    assert !assigns(:event).valid?
  end
  
  def test_edit
    get :edit, events(:birthday).to_path, as(:colin)
    assert_response :success
    assert_not_nil assigns(:event)
    assert_equal events(:birthday), assigns(:event)
  end
  
  def test_edit_by_non_allowed
    get :edit, events(:birthday).to_path, as(:alessandra)
    assert_redirected_to user_url(users(:alessandra))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_edit_without_login
    get :edit, events(:birthday).to_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_update
    put :update, events(:birthday).to_path.merge(:event => { :content => "birthday bash!" }), as(:colin)
    assert_redirected_to user_event_url(events(:birthday).to_path)
    assert_equal "You have successfully updated #{events(:birthday).display_name}.", flash[:notice]
  end
  
  def test_update_without_login
    put :update, events(:birthday).to_path.merge(:event => { :content => "birthday bash!" })
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]    
  end
  
  def test_update_by_unauthorized
    put :update, events(:birthday).to_path.merge(:event => { :content => "birthday bash!" }), as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]    
  end
  
  def test_update_with_wrong_nick
    put :update, events(:birthday).to_path.merge(:user_id => users(:colin).nick.chop, :event => { :content => "birthday bash!" }), as(:colin)
    assert_template 'error'
    assert_flash_equal "That User entry could not be found. Please check the address.", :warning
  end
  
  def test_begin_event
    put :begin_event, events(:birthday).to_path, as(:colin)
    assert_redirected_to user_event_url(events(:birthday).to_path)
    assert_equal "Your event #{events(:birthday).display_name} has officially begun!", flash[:notice]
  end
  
  def test_end_event
    put :end_event, events(:birthday).to_path, as(:colin)
    assert_redirected_to user_event_url(events(:birthday).to_path)
    assert_equal "Your event #{events(:birthday).display_name} has officially ended!", flash[:notice]
  end
  
  def test_destroy
    @request.env["HTTP_REFERER"] = "http://www.cnn.com/"
    delete :destroy, events(:birthday).to_path, as(:colin)
    assert_redirected_to "http://www.cnn.com/"
  end
end
