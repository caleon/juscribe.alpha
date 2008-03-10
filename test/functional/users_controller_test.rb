require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase
  def test_routing
    assert_routing '/users', :controller => 'users', :action => 'index'
    #assert_routing '/users', {:controller => 'users', :action => 'index', :page => '2'}, {:page => '2'}
    assert_routing '/users/colin', :controller => 'users', :action => 'show', :id => 'colin'
  end
  
  def test_index
    get :index
    assert_response :success
    assert_not_nil assigns(:objects)
    assert_not_nil assigns(:users)
    assert_template 'index'
    xhr :get, :index
    assert_response :success
    assert_template 'index'
  end
end
