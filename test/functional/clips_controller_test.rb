require File.dirname(__FILE__) + '/../test_helper'

class ClipsControllerTest < ActionController::TestCase
  
  def test_index
    get :index, users(:colin).to_path(true)
    assert_response :success
    assert_not_nil assigns(:widgetable)
    assert_equal users(:colin), assigns(:widgetable)
    assert_not_nil assigns(:clips)
    assert_template 'index'
  end
  
  def test_index_without_user_nick
    assert_raise(ActionController::RoutingError) { get :index }
  end
  
  def test_index_with_wrong_nick
    get :index, { :user_id => users(:colin).nick.chop }
    assert_nil assigns(:clips)
    assert_flash_equal "Unable to find the object specified. Please check the address.", :warning
  end
  
  def test_index_with_diff_user_but_private
    users(:colin).rule.toggle_privacy!
    assert users(:colin).private?
    assert !users(:colin).accessible_by?(users(:nana))
    get :index, users(:colin).to_path(true), as(:nana)
    assert_redirected_to user_url(users(:nana)), users(:colin).to_path(true).inspect
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_index_with_no_user_but_private
    users(:colin).rule.toggle_privacy!
    assert users(:colin).private?
    get :index, users(:colin).to_path(true)
    assert_redirected_to login_url
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_show
    get :show, widgets(:colin_clip).to_path
    assert_response :success
    assert_equal widgets(:colin_clip), assigns(:clip)
  end
  
  def test_show_with_login
    get :show, widgets(:colin_clip).to_path, as(:colin)
    assert_response :success
    assert_equal widgets(:colin_clip), assigns(:clip)
  end
  
  def test_show_with_diff_login
    get :show, widgets(:colin_clip).to_path, as(:keira)
    assert_response :success
    assert_equal widgets(:colin_clip), assigns(:clip)
  end
  
  def test_show_without_login_but_private
    users(:colin).rule.toggle_privacy!
    assert users(:colin).private?
    get :show, widgets(:colin_clip).to_path
    assert_redirected_to login_url
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_show_with_diff_login_but_private
    users(:colin).rule.toggle_privacy!
    assert users(:colin).private?
    get :show, widgets(:colin_clip).to_path, as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_new
    get :new, users(:colin).to_path(true), as(:colin)
    assert_response :success
    assert_not_nil assigns(:clip)
    assert assigns(:clip).new_record?
  end
  
  def test_new_without_login
    get :new, users(:colin).to_path(true)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
 
  def test_new_with_diff_user
    get :new, users(:colin).to_path(true), as(:nana)
    assert_response :success
    assert_not_nil assigns(:clip)
    assert assigns(:clip).new_record?
  end
  
  def test_new_with_non_user
    get :new, users(:colin).to_path(true), as(12312312312312)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_new_with_diff_user_but_private
    users(:colin).rule.toggle_privacy!
    assert users(:colin).private?
    assert !users(:colin).accessible_by?(users(:nana))
    get :new, users(:colin).to_path(true), as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_new_with_same_user_but_private
    users(:colin).rule.toggle_privacy!
    assert users(:colin).private?
    assert users(:colin).accessible_by?(users(:colin))
    get :new, users(:colin).to_path(true), as(:colin)
    assert_response :success
    assert_not_nil assigns(:clip)
    assert assigns(:clip).new_record?
  end
  
  def test_create
    post :create, users(:keira).to_path(true).merge(:clip => { :name => 'blahwidget' }), as(:keira)
#    assert_not_nil assigns(:clip)
#    assert assigns(:clip).valid?
    assert_redirected_to user_url(users(:keira))
    assert_equal "You have clipped #{flash_name_for(users(:keira))}.", flash[:notice]
  end
  
  def test_create_with_diff_user
    post :create, users(:keira).to_path(true).merge(:clip => { :name => 'blahwidget' }), as(:nana)
#    assert_not_nil assigns(:clip)
#    assert assigns(:clip).valid?
    assert_redirected_to user_url(users(:keira))
    assert_equal "You have clipped #{flash_name_for(users(:keira))}.", flash[:notice]
 end
  
  def test_create_with_non_user
    post :create, users(:keira).to_path(true).merge(:clip => { :name => 'blahwidget' })
    assert_nil assigns(:clip)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_create_with_diff_user_but_private
    users(:keira).rule.toggle_privacy!
    assert users(:keira).private?
    assert !users(:keira).accessible_by?(users(:nana))
    post :create, users(:keira).to_path(true).merge(:clip => { :name => 'blahwidget' }), as(:nana)
    assert_equal "You are not authorized for that action.", flash[:warning]
    assert_redirected_to user_url(users(:nana))
  end
  
  def test_create_with_same_user_but_private
    users(:keira).rule.toggle_privacy!
    assert users(:keira).private?
    assert users(:keira).accessible_by?(users(:keira))
    post :create, users(:keira).to_path(true).merge(:clip => { :name => 'blahwidget' }), as(:keira)
#    assert_not_nil assigns(:clip)
#    assert assigns(:clip).valid?
    assert_redirected_to user_url(users(:keira))
    assert_equal "You have clipped #{flash_name_for(users(:keira))}.", flash[:notice]
  end
  
  def test_edit
    get :edit, widgets(:colin_clip).to_path, as(:colin)
    assert_response :success
    assert_not_nil assigns(:clip)
    assert_equal widgets(:colin_clip), assigns(:clip)
  end
  
  def test_edit_by_non_allowed
    get :edit, widgets(:colin_clip).to_path, as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_edit_without_login
    get :edit, widgets(:colin_clip).to_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_update
    put :update, widgets(:colin_clip).to_path.update(:clip => { :name => 'blah' }), as(:colin)
    assert_redirected_to user_url(users(:colin))
    assert_equal "You have successfully updated #{flash_name_for(widgets(:colin_clip))}.", flash[:notice]
  end
  
  def test_update_without_login
    put :update, widgets(:colin_clip).to_path.update(:clip => { :name => 'blah' })
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_update_by_unauthorized
    put :update, widgets(:colin_clip).to_path.update(:clip => { :name => 'blah' }), as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_update_with_wrong_nick
    put :update, widgets(:colin_clip).to_path.update(:clip => { :name => 'blah' }, :user_id => users(:colin).nick.chop), as(:colin)
    assert_template 'error'
    assert_flash_equal "That User could not be found. Please check the address.", :warning
  end
 
  def test_destroy
    delete :destroy, widgets(:colin_clip).to_path, as(:colin)
    assert_redirected_to user_url(users(:colin))
    assert_equal "You have unclipped #{flash_name_for(users(:colin))}.", flash[:notice]
  end
  
  def test_destroy_by_random_user
    delete :destroy, widgets(:colin_clip).to_path, as(:alessandra)
    assert_redirected_to user_url(users(:alessandra))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_destroy_by_owner_of_widgetable
    articles(:blog).publish!
    assert_equal users(:colin), articles(:blog).user
    assert_equal users(:nana), widgets(:article_clip).user
    assert_equal articles(:blog), widgets(:article_clip).widgetable
    assert widgets(:article_clip).accessible_by?(users(:nana))
    assert widgets(:article_clip).accessible_by?(users(:colin))
    assert articles(:blog).public?
    articles(:blog).rule.toggle_privacy!
    assert articles(:blog).private?
    assert widgets(:article_clip).reload.accessible_by?(users(:colin))
    assert !widgets(:article_clip).reload.accessible_by?(users(:nana)), widgets(:article_clip).inspect
    
    delete :destroy, widgets(:article_clip).to_path, as(:colin)
    assert_redirected_to user_blog_article_url(articles(:blog).to_path), articles(:blog).to_path.inspect
    assert_equal "You have unclipped #{flash_name_for(articles(:blog))}.", flash[:notice]
  end
end
