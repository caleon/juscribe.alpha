require File.dirname(__FILE__) + '/../test_helper'

class BlogsControllerTest < ActionController::TestCase

  def test_index
    get :index, users(:colin).to_path(true)
    assert_response :success
    assert_not_nil assigns(:bloggable)
    assert_not_nil assigns(:blogs)
    assert assigns(:blogs).is_a?(Array)
  end
  
  def test_index_without_bloggable
    assert_raise(ActionController::RoutingError) { get :index }
  end
  
  def test_index_with_wrong_bloggable_user
    get :index, { :user_id => users(:colin).nick.chop }
    assert_nil assigns(:blogs)
    assert_flash_equal "That User could not be found. Please check the address.", :warning
  end
  
  def test_index_with_wrong_bloggable_group
    get :index, { :group_id => 12312312312 }
    assert_nil assigns(:blogs)
    assert_flash_equal "That Group could not be found. Please check the address.", :warning
  end
  
  def test_show
    assert blogs(:first).valid?
    get :show, blogs(:first).to_path, as(:colin)
    assert_equal users(:colin), assigns(:bloggable)
    assert_response :success
    assert_equal blogs(:first), assigns(:blog)
  end
  
  def test_show_without_bloggable
    assert_raise(ActionController::RoutingError) { get :show, { :id => blogs(:first).to_param }, as(:colin) }
  end
  
  def test_show_without_login_on_protected
    blogs(:first).rule.toggle_privacy!
    get :show, blogs(:first).to_path, as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_new
    get :new, groups(:company).to_path(true), as(:colin)
    assert_response :success
    assert_not_nil assigns(:bloggable)
    assert_equal groups(:company), assigns(:bloggable)
    assert assigns(:blog).new_record?
    assert_equal groups(:company), assigns(:blog).bloggable
  end
  
  def test_new_with_unauthorized_user
    get :new, groups(:company).to_path(true), as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_new_with_no_user
    get :new, groups(:company).to_path(true)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_new_with_no_user_but_private
    groups(:company).rule.toggle_privacy!
    assert groups(:company).private?
    get :new, groups(:company).to_path(true)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_new_as_owner_but_private
    groups(:company).rule.toggle_privacy!
    assert groups(:company).private?
    get :new, groups(:company).to_path(true), as(:colin)
    assert_response :success
    assert_not_nil assigns(:blog)
    assert_equal groups(:company), assigns(:bloggable)
    assert assigns(:blog).new_record?
  end
  
  def test_create
    post :create, groups(:company).to_path(true).merge(:blog => { :name => 'newsletter' }), as(:colin)
    assert_not_nil assigns(:blog)
    assert assigns(:blog).valid?
    assert_redirected_to group_blog_url(assigns(:blog).to_path)
    assert_equal "You have successfully created your blog.", flash[:notice]
  end
  
  def test_create_with_non_user
    post :create, groups(:company).to_path(true).merge(:blog => { :name => 'newsletter' })
    assert_nil assigns(:blog)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_create_with_diff_user
    post :create, groups(:company).to_path(true).merge(:blog => { :name => 'newsletter' }), as(:keira)
    assert_equal groups(:company), assigns(:bloggable)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_create_with_member_of_group_but_private
    groups(:company).join(users(:keira))
    assert groups(:company).users.include?(users(:keira))
    assert groups(:company).accessible_by?(users(:keira))
    post :create, groups(:company).to_path(true).merge(:blog => { :name => 'newsletter' }), as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_create_with_member_promoted_to_admin
    groups(:company).join(users(:keira))
    assert groups(:company).accessible_by?(users(:keira))
    assert !groups(:company).editable_by?(users(:keira))
    assert groups(:company).assign_rank(users(:keira), Membership::ADMIN_RANK)
    assert groups(:company).editable_by?(users(:keira))
    post :create, groups(:company).to_path(true).merge(:blog => { :name => 'newsletter' }), as(:keira)
    assert_redirected_to group_blog_url(assigns(:blog).to_path)
    assert_equal "You have successfully created your blog.", flash[:notice]
  end
  
  def test_edit_as_creator_of_blog
    get :edit, blogs(:company).to_polypath, as(:colin)
    assert_response :success
    assert_equal blogs(:company), assigns(:blog)
  end
  
  def test_edit_as_random
    get :edit, blogs(:company).to_polypath, as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_edit_as_non_logged
    get :edit, blogs(:company).to_polypath
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_edit_as_member
    groups(:company).join(users(:keira))
    assert groups(:company).accessible_by?(users(:keira))
    get :edit, blogs(:company).to_polypath, as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_edit_as_admin
    groups(:company).join(users(:keira), :rank => Membership::ADMIN_RANK)
    assert groups(:company).accessible_by?(users(:keira))
    assert groups(:company).editable_by?(users(:keira))
    get :edit, blogs(:company).to_polypath, as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_edit_as_blog_authorized
    groups(:company).join(users(:keira), :rank => Membership::ADMIN_RANK)
    assert groups(:company).accessible_by?(users(:keira))
    assert groups(:company).editable_by?(users(:keira))
    assert !blogs(:company).editable_by?(users(:keira))
    blogs(:company).rule.add_boss!(:user, users(:keira))
    assert blogs(:company).editable_by?(users(:keira))
    get :edit, blogs(:company).to_polypath, as(:keira)
    assert_response :success
    assert_equal blogs(:company), assigns(:blog)
  end
  
  def test_update_as_owner
    put :update, blogs(:company).to_polypath.merge(:blog => { :description => 'laaaaaa' }), as(:colin)
    assert_redirected_to group_blog_url(blogs(:company).to_path)
    assert_equal "You have successfully updated #{blogs(:company).display_name}.", flash[:notice]
  end
  
  def test_update_as_non_logged
    put :update, blogs(:company).to_polypath.merge(:blog => { :description => 'laaaaaa' })
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_update_as_random
    put :update, blogs(:company).to_polypath.merge(:blog => { :description => 'laaaaaa' }), as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_update_as_member
    groups(:company).join(users(:keira))
    put :update, blogs(:company).to_polypath.merge(:blog => { :description => 'laaaaaa' }), as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_update_as_admin
    groups(:company).join(users(:keira), :rank => Membership::ADMIN_RANK)
    put :update, blogs(:company).to_polypath.merge(:blog => { :description => 'laaaaa' }), as(:keira)
    assert_redirected_to user_url(users(:keira))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_update_as_boss
    blogs(:company).rule.add_boss!(:user, users(:keira))
    assert blogs(:company).editable_by?(users(:keira))
    put :update, blogs(:company).to_polypath.merge(:blog => { :description => 'laaaaaa' }), as(:keira)
    assert_redirected_to group_blog_url(blogs(:company).to_path)
    assert_equal "You have successfully updated #{blogs(:company).display_name}.", flash[:notice]
  end
  
  def test_update_as_boss_though_private
    blogs(:company).rule.add_boss!(:user, users(:keira))
    blogs(:company).rule.toggle_privacy!
    assert blogs(:company).private?
    put :update, blogs(:company).to_polypath.merge(:blog => { :description => 'laaaaaa' }), as(:keira)
    assert_redirected_to group_blog_url(blogs(:company).to_path)
    assert_equal "You have successfully updated #{blogs(:company).display_name}.", flash[:notice]
  end
  
  def test_destroy_as_owner
    @request.env["HTTP_REFERER"] = "http://www.cnn.com/"
    delete :destroy, blogs(:company).to_polypath, as(:colin)
    assert_equal "You have successfully deleted #{blogs(:company).display_name}.", flash[:notice]
    assert_redirected_to "http://www.cnn.com/"
  end
end
