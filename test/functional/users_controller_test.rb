require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase
  def test_routing
    assert_routing '/u', :controller => 'users', :action => 'index'
    #assert_routing '/users', {:controller => 'users', :action => 'index', :page => '2'}, {:page => '2'}
    assert_routing '/u/colin', :controller => 'users', :action => 'show', :id => 'colin'
  end
  
  def test_index
    get :index
    assert_nil assigns(:viewer)
    assert_response :success
    assert_not_nil assigns(:users)
    assert_template 'index'
    xhr :get, :index
    assert_nil assigns(:viewer)
    assert_response :success
    assert_not_nil assigns(:users)
    assert_template 'index'
    get :index, :format => 'xml'
    assert_response :success
    assert_not_nil assigns(:users)
    assert_template 'index'
  end
  
  def test_show
    get :show, users(:colin).to_path
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:widgets)
    # assert_not_nil assigns(:skin_file) this is nil until layout is set
    xhr :get, :show, users(:colin).to_path
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:widgets)
    # assert_not_nil assigns(:skin_file) this is nil until layout is set
    get :show, users(:colin).to_path.merge(:format => 'xml')
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:widgets)
  end
  
  def test_new
    get :new
    assert_response :success
    assert_template 'new'
    assert_equal 'Become a new Juscribe member!', assigns(:page_title)
    assert_not_nil assigns(:user)
    xhr :get, :new
    assert_response :success
    assert_template 'new'
    assert_equal 'Become a new Juscribe member!', assigns(:page_title)
  end
  
  def test_create_with_invalid_entries
    post :create, :user => { :nick => '  2', :first_name => 'bam', :last_name => 'bam', :password => 'bambam', :password_confirmation => 'bambam', :birthdate => Date.new(1984, 1, 4), :email => 'doggie@.com' }
    assert_response :success
    assert_template 'new'
    assert_flash_equal 'There was an issue with the registration form.', :warning
  end
    
  def test_create
    post :create, :user => { :nick => 'Bam_bam', :first_name => 'bam', :last_name => 'bam', :password => 'bambam', :password_confirmation => 'bambam', :birthdate => Date.parse('1/29/1985'), :sex => "1", :email => 'bambam@venturous.net' }
    assert_redirected_to :action => 'show', :id => 'Bam_bam'
    assert_equal "You are now a registered user! Welcome!", flash[:notice]
    assert_not_nil assigns(:user)
    assert_equal User.find_by_nick('Bam_bam'), assigns(:user)
    assert_not_nil assigns(:viewer)
  end
  
  def test_create_with_picture
    # TODO fixture_file_upload("screen.png", "image/png")
  end
  
  def test_edit_with_no_user
    get :edit, users(:colin).to_path
    assert_redirected_to :action => 'login'
    assert_equal 'You need to be logged in to do that.', flash[:warning]
  end
  
  def test_edit_with_wrong_user
    get :edit, users(:colin).to_path, as(:keira)
    assert_redirected_to :action => 'show', :id => users(:keira).nick
    assert_equal 'You are not authorized for that action.', flash[:warning]
  end
  
  def test_edit_with_same_user
    get :edit, users(:colin).to_path, as(:colin)
    assert_equal users(:colin), assigns(:viewer)
    assert_response :success
    assert_template 'edit'
    assert_equal "#{users(:colin).display_name} - Edit", assigns(:page_title)
  end
  
  def test_update_with_no_user
    put :update, users(:colin).to_path.update(:user => { :first_name => 'caleon' })
    assert_redirected_to :action => 'login'
    assert_equal 'You need to be logged in to do that.', flash[:warning]
  end
  
  def test_update_with_wrong_user
    put :update, users(:colin).to_path.update(:user => { :first_name => 'caleon' }), as(:keira)
    assert_redirected_to :action => 'show', :id => users(:keira).nick
    assert_equal 'You are not authorized for that action.', flash[:warning]
  end
  
  def test_update_with_correct_user
    put :update, users(:colin).to_path.update(:user => { :first_name => 'caleon' }), as(:colin)
    assert_redirected_to :action => 'show', :id => users(:colin).nick
    assert_equal "You have successfully updated your profile.", flash[:notice]
  end
  
  def test_update_invalid_entries
    put :update, users(:colin).to_path.update(:user => { :first_name => 'c' }), as(:colin)
    assert_template 'edit'
    assert_equal users(:colin), assigns(:user)
    assert_flash_equal "There was an error updating your profile.", :warning
  end
  
  def test_edit_password_correct
    get :edit_password, users(:colin).to_path, as(:colin)
    assert_response :success
    assert_equal 'colin - Edit Password', assigns(:page_title)
  end
    
  def test_edit_password_without_param
    assert_raise(ActionController::RoutingError) { get :edit_password }
  end
  
  def test_edit_password_with_nick_param
    get :edit_password, :id => 'colin'
    assert_redirected_to :action => 'login'
    assert_equal 'You need to be logged in to do that.', flash[:warning]
  end
  
  def test_edit_password_for_someone_else
    get :edit_password, users(:colin).to_path, as(:nana)
    assert_redirected_to :action => 'show', :id => users(:nana).nick
    assert_equal 'You are not authorized for that action.', flash[:warning]
  end
  
  def test_edit_password_for_non_user
    get :edit_password, { :id => 'keira' }, as(:nana)
    assert_template 'error'
    assert_flash_equal 'That User entry could not be found. Please check the address.', :warning
  end
  
  def test_update_password
    put :update_password, users(:colin).to_path.update(:user => { :password => 'new_password', :password_confirmation => 'new_password' }), as(:colin)
    assert_redirected_to user_url(users(:colin))
    assert_equal "You have successfully changed your password.", flash[:notice]
  end
  
  def test_update_password_by_wrong_user
    put :update_password, users(:colin).to_path.update(:user => { :password => 'blah', :password_confirmation => 'blah' }), as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal 'You are not authorized for that action.', flash[:warning]
  end
  
  def test_update_password_by_non_user
    put :update_password, users(:colin).to_path.update(:user => { :password => 'blah', :password_confirmation => 'blah' }), { :id => 12312313 }
    assert_redirected_to login_url
    assert_equal 'You need to be logged in to do that.', flash[:warning]
  end
  
  def test_update_password_for_non_user
    put :update_password, { :id => 'colina', :user => { :pasword => 'boo', :password_confirmation => 'boo' }}, as(:colin)
    assert_template 'error'
    assert_flash_equal 'That User entry could not be found. Please check the address.', :warning
  end
  
  def test_login_page
    get :login
    assert_response :success
    assert_equal "Login", assigns(:page_title)
    assert assigns(:user).new_record?
  end
  
  def test_login_when_already_logged_in
    get :login, {}, as(:colin)
    assert_redirected_to user_url(users(:colin))
    assert_equal "You are already logged in.", flash[:notice]
  end
  
  def test_login_submit
    post :login, { :user => { :nick => 'colin', :password => 'this is a test' } }
    assert_redirected_to user_url(users(:colin))
    assert_equal "You are now logged in.", flash[:notice]
  end
  
  def test_login_wrong_password
    post :login, { :user => { :nick => 'colin', :password => 'this isnt a test' } }
    assert_template 'login'
    assert_flash_equal 'There was an error logging you in.', :warning
  end
  
  def test_login_wrong_nick
    post :login, { :user => { :nick => 'colina', :password => 'this is a test' } }
    assert_template 'login'
    assert_flash_equal 'There was an error logging you in.', :warning
  end
  
  def test_logout
    get :logout, {}, as(:colin)
    assert_redirected_to user_url(users(:colin))
    assert_equal 'You are now logged out. See you soon!', flash[:notice]
    assert_nil session[:id]
    assert_nil assigns(:viewer)
  end
  
  def test_mine
    get :mine, {}, as(:keira)
    assert_redirected_to user_url(users(:keira))
  end
  
  def test_mine_without_login
    get :mine
    assert_redirected_to login_url
  end
  
  def test_friends
    get :friends, users(:colin).to_path
    assert_response :success
    assert_equal users(:colin), assigns(:user)
    assert assigns(:friends).is_a?(Array)
  end
  
  def test_friends_without_nick
    assert_raise(ActionController::RoutingError) { get :friends }
  end
  
  def test_befriend
    put :befriend, users(:keira).to_path, as(:colin)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You have requested friendship with #{users(:keira).display_name}.", flash[:notice]
  end
  
  def test_befriend_without_nick
    assert_raise(ActionController::RoutingError) { put :befriend }
  end
  
  def test_befriend_twice
    put :befriend, users(:keira).to_path, as(:colin)
    assert_redirected_to user_url(users(:keira))
    put :befriend, users(:keira).to_path, as(:colin)
    assert_flash_equal "There was an error friending #{users(:keira).display_name}.", :warning
  end
  
  def test_mutual_friending
    users(:keira).befriend(users(:colin))
    put :befriend, users(:keira).to_path, as(:colin)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are now friends with #{users(:keira).display_name}.", flash[:notice]
  end
  
  def test_unfriend
    users(:colin).befriend(users(:keira))
    put :unfriend, users(:keira).to_path, as(:colin)
    assert_redirected_to user_url(users(:colin))
    assert_equal "You are no longer friends with #{users(:keira).display_name}.", flash[:notice]
  end
  
  def test_unfriend_non_friend
    put :unfriend, users(:keira).to_path, as(:colin)
    assert_flash_equal "You cannot unfriend #{users(:keira).display_name}.", :warning
  end
  
  def test_about
    get :about, users(:colin).to_path
    assert_response :success, users(:colin).to_path.inspect
    assert_equal users(:colin), assigns(:user)
  end
  
  def test_about_without_nick
    assert_raise(ActionController::RoutingError) { get :about }
  end
  
  def test_about_with_non_user
    get :about, { :id => 'blahblah' }
    #assert_template 'error'
    assert_flash_equal "That User entry could not be found. Please check the address.", :warning
  end
  
  def test_destroy
    @request.env["HTTP_REFERER"] = "http://www.cnn.com/"
    users(:colin).update_attribute(:admin, true)
    assert users(:alessandra).editable_by?(users(:colin))
    delete :destroy, users(:alessandra).to_path, as(:colin)
    assert_response :redirect
    assert_redirected_to "http://www.cnn.com/"
    assert_equal "You have deleted #{users(:alessandra).display_name}.", flash[:notice]
  end
end
