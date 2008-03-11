require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase
  def test_routing
    assert_routing '/users', :controller => 'users', :action => 'index'
    #assert_routing '/users', {:controller => 'users', :action => 'index', :page => '2'}, {:page => '2'}
    assert_routing '/users/colin', :controller => 'users', :action => 'show', :id => 'colin'
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
    get :show, { :id => 'colin' }
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:widgets)
    assert_not_nil assigns(:skin_file)
    assert_not_nil assigns(:layout_file)
    xhr :get, :show, { :id => 'colin' }
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:widgets)
    assert_not_nil assigns(:skin_file)
    assert_not_nil assigns(:layout_file)
    get :show, { :id => 'colin', :format => 'xml' }
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:widgets)
  end
  
  def test_new
    get :new
    assert_response :success
    assert_template 'new'
    assert_equal 'Create user', assigns(:page_title)
    assert_not_nil assigns(:user)
    xhr :get, :new
    assert_response :success
    assert_template 'new'
    assert_equal 'Create user', assigns(:page_title)
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
  
  def test_edit_with_no_user
    get :edit, { :id => 'colin' }
    assert_response 401
    assert_template nil
  end
  
  def test_edit_with_wrong_user
    get :edit, { :id => 'colin' }, { :user_id => 'keira'.hash.abs }
    assert_response 401
    assert_template nil    
  end
  
  def test_edit_with_same_user
    get :edit, { :id => 'colin' }, { :user_id => 'colin'.hash.abs }
    assert_equal users(:colin), assigns(:viewer)
    assert_response :success
    assert_template 'edit'
    assert_equal "#{users(:colin).display_name} - Edit", assigns(:page_title)
  end
  
  def test_update
    
  end
  
  def test_edit_password
    get :edit_password, { :id => 'colin' }
    assert_response 401
    get :edit_password, { :id => 'colin' }, { :user_id => 3 }
    assert_response 401
  end
end
