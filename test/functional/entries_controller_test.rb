require File.dirname(__FILE__) + '/../test_helper'

class EntriesControllerTest < ActionController::TestCase

  def test_index
    get :index, entries(:happenings).hash_for_path
  end
  
  def test_show
    get :show, entries(:happenings).hash_for_path
  end
  
  def test_new
    get :new, { :user_id => users(:colin).to_param }, { :id => users(:colin).id }
  end
  
  #def test_create
  #  post :create, { :user_id => users(:colin).to_param }, { :id => users(:colin).id }
  #end
  
  def test_edit
    
  end
  
  def test_update
    
  end
  
  def test_destroy
    
  end
end
