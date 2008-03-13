require File.dirname(__FILE__) + '/../test_helper'

class EntriesControllerTest < ActionController::TestCase

  def test_index
    get :index, entries(:happenings).to_path
  end
  
  def test_show
    get :show, entries(:happenings).to_path
  end
  
  def test_new
    get :new, { :user_id => users(:colin).to_param }, as(:colin)
  end
  
  def test_create
    post :create, { :user_id => users(:colin).to_param, :entry => { :user_id => users(:colin).id, :content => 'boogity-boo!' } }, as(:colin)
    assert_not_nil assigns(:entry)
    assert assigns(:entry).valid?, assigns(:entry).errors.inspect
    assert_redirected_to user_entry_url(assigns(:entry).to_path)
    assert_equal "You have successfully created your Entry.", flash[:notice]
  end
  
  def test_edit
    get :edit, entries(:happenings).to_path, as(:colin)
  end
  
  def test_update
    put :update, entries(:happenings).to_path.update(:entry => { :location => 'somewhere' }), as(:colin)
  end
  
  def test_destroy
    
  end
end
