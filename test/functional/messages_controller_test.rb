require File.dirname(__FILE__) + '/../test_helper'

class MessagesControllerTest < ActionController::TestCase
  
  def test_index_without_login
    get :index
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_index_with_non_user
    get :index, {}, as(123424134)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_index
    get :index, {}, as(:colin)
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:messages)
    assert assigns(:messages).is_a?(Array)
  end
  
  def test_index_sent
    get :index, { :show => 'sent' }, as(:colin)
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:messages)
    assert assigns(:messages).is_a?(Array)
  end
  
  def test_index_weird
    get :index, { :show => 'blahla' }, as(:colin)
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:messages)
    assert assigns(:messages).is_a?(Array)
  end
  
  def test_show
    get :show, { :id => messages(:colin_to_nana).id }, as(:colin)
    assert_response :success
    assert_template 'show'
    assert_equal messages(:colin_to_nana), assigns(:message)
  end
  
  def test_show_for_recipient
    get :show, { :id => messages(:colin_to_nana).id }, as(:nana)
    assert_response :success
    assert_template 'show'
    assert_equal messages(:colin_to_nana), assigns(:message)
  end
  
  def test_show_for_non_participant
    get :show, { :id => messages(:colin_to_nana).id }, as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_create
    post :create, { :message => { :recipient => users(:keira).nick, :subject => 'dynamiiiiiic', :body => 'hello you, lets get together sometime.' } }, as(:colin)
    assert_not_nil assigns(:message)
    assert_redirected_to message_url(assigns(:message))
    assert_equal "You have sent your message to kknight.", flash[:notice]
  end
  
  def test_create_invalid_recipient
    post :create, { :message => { :recipient => 'keira', :subject => 'flkajsdlfkjasdflj', :body => 'alskdfja;sldkfja;sdfjk' } }, as(:colin)
    assert_nil assigns(:message)
    assert_flash_equal 'There was an error creating your message.', :warning
  end
  
  def test_create_invalidly
    post :create, { :message => { :recipient => users(:alessandra).nick, :subject => '', :body => '' } }, as(:colin)
    assert_not_nil assigns(:message)
    assert !assigns(:message).errors.empty?
    assert_flash_equal 'There was an error creating your message.', :warning
  end
  
end
