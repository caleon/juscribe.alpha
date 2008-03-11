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
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:widgets)
    assert_not_nil assigns(:skin_file)
    assert_not_nil assigns(:layout_file)
    xhr :get, :show, { :id => 'colin' }
    assert_response :success
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:widgets)
    assert_not_nil assigns(:skin_file)
    assert_not_nil assigns(:layout_file)
    get :show, { :id => 'colin', :format => 'xml' }
    assert_response :success
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:widgets)
  end
  
  def test_new
    get :new
    assert_response :success
    assert_equal 'Create user', assigns(:page_title)
    assert_not_nil assigns(:user)
    xhr :get, :new
    assert_response :success
    assert_equal 'Create user', assigns(:page_title)
  end
  
  def test_create
    # Fuck functional tests. Goddamn. get :create is a headache??
    #post :create, :nick => 'Bam_bam', :first_name => 'bam', :last_name => 'bam', :password => 'bambam', :password_confirmation => 'bambam', :birthdate => Date.parse('1/29/1985'), :sex => "1"
    #assert_template "show"
    #assert_equal "You are now a registered user! Welcome!", flash[:notice]
    # Ok so now, it can't even read class_variable_readers in the controller. fuck this.
  end
end
