require File.dirname(__FILE__) + '/../test_helper'

class CommentsControllerTest < ActionController::TestCase

  def test_index
    articles(:blog).publish!
    assert articles(:blog).published?
    get :index, articles(:blog).to_path(true)
    assert_response :success
    assert_not_nil assigns(:commentable)
    assert_equal articles(:blog), assigns(:commentable)
    assert_template 'index'
  end
  
  def test_index_without_user_nick
    assert_raise(ActionController::RoutingError) { get :index }
  end
  
  def test_index_with_wrong_path
    articles(:blog).publish!
    get :index, articles(:blog).to_path(true).update(:article_id => articles(:blog).permalink.chop)
    assert_nil assigns(:comment)
    assert_template 'error'
    assert_flash_equal "Unable to find the object specified. Please check the address.", :warning
  end
  
  def test_index_with_diff_user_but_private
    articles(:promo).publish!
    assert articles(:promo).published?
    articles(:promo).rule.toggle_privacy!
    assert articles(:promo).private?
    assert !articles(:promo).accessible_by?(users(:nana))
    get :index, articles(:promo).to_path(true), as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_index_with_no_user_but_private
    articles(:promo).publish!
    articles(:promo).rule.toggle_privacy!
    assert articles(:promo).private?
    get :index, articles(:promo).to_path(true)
    assert_redirected_to login_url
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_show
    articles(:blog).publish!
    get :show, comments(:blog_comment).to_path
    assert_response :success
    assert_equal comments(:blog_comment), assigns(:comment)
  end
  
  def test_show_as_owner_of_commentable
    articles(:blog).publish!
    get :show, comments(:blog_comment).to_path, as(:colin)
    assert_response :success
    assert_equal comments(:blog_comment), assigns(:comment)
  end
  
  def test_show_as_owner_of_comment
    articles(:blog).publish!
    get :show, comments(:blog_comment).to_path, as(:keira)
    assert_response :success
    assert_equal comments(:blog_comment), assigns(:comment)
  end
  
  def test_show_as_random_person
    articles(:blog).publish!
    get :show, comments(:blog_comment).to_path, as(:nana)
    assert_response :success
    assert_equal comments(:blog_comment), assigns(:comment)
  end
  
  def test_show_without_login_but_private_commentable
    articles(:blog).publish!
    articles(:blog).rule.toggle_privacy!
    assert articles(:blog).reload.private?
    assert articles(:blog).accessible_by?(users(:colin))
    get :show, comments(:blog_comment).to_path
    assert_redirected_to login_url
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_show_with_diff_login_but_private_commentable
    articles(:blog).publish!
    articles(:blog).rule.toggle_privacy!
    assert articles(:blog).reload.private?
    get :show, comments(:blog_comment).to_path, as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_show_with_private_commentable_as_owner_of_comment
    assert comments(:blog_comment).accessible_by?(users(:keira))
    assert !articles(:blog).accessible_by?(users(:keira))
    articles(:blog).publish!
    articles(:blog).rule.toggle_privacy!
    assert !articles(:blog).reload.accessible_by?(users(:keira))
    assert_equal articles(:blog), comments(:blog_comment).commentable
    assert comments(:blog_comment).accessible_by?(users(:keira))
    get :show, comments(:blog_comment).to_path, as(:keira)
    assert_response :success
    assert_equal comments(:blog_comment), assigns(:comment)
  end
  
  def test_new # as owner of commentable
    articles(:blog).publish!
    get :new, articles(:blog).to_path(true), as(:colin)
    assert_response :success
    assert_not_nil assigns(:comment)
    assert assigns(:comment).new_record?
  end
  
  def test_new_as_random_user
    articles(:blog).publish!
    assert articles(:blog).accessible_by?(users(:nana))
    get :new, articles(:blog).to_path(true), as(:nana)
    assert_response :success
    assert assigns(:comment).new_record?
  end
  
  def test_new_without_login
    articles(:blog).publish!
    assert articles(:blog).accessible_by?(nil)
    get :new, articles(:blog).to_path(true)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_new_with_non_user
    articles(:blog).publish!
    get :new, articles(:blog).to_path(true), as(123123123123)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_new_with_diff_user_but_private
    articles(:blog).publish!
    articles(:blog).rule.toggle_privacy!
    assert articles(:blog).reload.private?
    assert !articles(:blog).accessible_by?(users(:nana))
    get :new, articles(:blog).to_path(true), as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_new_as_owner_but_private
    articles(:blog).publish!
    articles(:blog).rule.toggle_privacy!
    assert articles(:blog).reload.private?
    assert_equal users(:colin), articles(:blog).user
    assert articles(:blog).accessible_by?(users(:colin))
    get :new, articles(:blog).to_path(true), as(:colin)
    assert_response :success
    assert assigns(:comment).new_record?
  end
  
  def test_create
    articles(:blog).send(:make_permalink, :with_save => true)
    articles(:blog).publish!
    post :create, articles(:blog).to_path(true).merge(:comment => { :body => 'blah blah' }), as(:nana)
    assert_not_nil assigns(:comment)
    assert assigns(:comment).valid?
    assert_redirected_to user_blog_article_url(articles(:blog).to_path) + "#comment-#{assigns(:comment).id}"
    assert_equal "You have commented on #{articles(:blog).display_name}.", flash[:notice]
  end
  
  def test_create_with_non_user
    articles(:blog).publish!
    post :create, articles(:blog).to_path(true).merge(:comment => { :body => 'blah blah' })
    assert_nil assigns(:comment)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_create_with_diff_user_but_private
    articles(:blog).publish!
    articles(:blog).rule.toggle_privacy!
    assert articles(:blog).reload.private?
    assert !articles(:blog).accessible_by?(users(:nana))
    post :create, articles(:blog).to_path(true).merge(:comment => { :body => 'blah blah' }), as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_create_with_same_user_but_private
    articles(:blog).publish!
    articles(:blog).rule.toggle_privacy!
    assert articles(:blog).reload.private?
    assert_equal users(:colin), articles(:blog).user
    assert articles(:blog).accessible_by?(users(:colin))
    post :create, articles(:blog).to_path(true).merge(:comment => { :body => 'blah blah' }), as(:colin)
    assert_redirected_to user_blog_article_url(articles(:blog).to_path) + "#comment-#{assigns(:comment).id}"
    assert_equal "You have commented on #{articles(:blog).display_name}.", flash[:notice]
  end
  
  def test_edit_as_comment_owner
    articles(:blog).publish!
    get :edit, comments(:blog_comment).to_path, as(:keira)
    assert_response :success
    assert_equal comments(:blog_comment), assigns(:comment)
  end
  
  def test_edit_as_non_comment_owner
    articles(:blog).publish!
    get :edit, comments(:blog_comment).to_path, as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_edit_as_commentable_owner
    articles(:blog).publish!
    get :edit, comments(:blog_comment).to_path, as(:colin)
    assert_response :success
    assert_equal comments(:blog_comment), assigns(:comment)
  end
  
  def test_update_as_non_user
    articles(:blog).publish!
    get :edit, comments(:blog_comment).to_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_update_as_comment_owner
    articles(:blog).publish!
    put :update, comments(:blog_comment).to_path.merge(:comment => { :body => 'blah blah' }), as(:keira)
    assert_redirected_to user_blog_article_url(articles(:blog).to_path) + "#comment-#{assigns(:comment).id}"
    assert_equal "You have successfully updated #{comments(:blog_comment).display_name}.", flash[:notice]
    assert_equal 'blah blah', comments(:blog_comment).reload.body
  end
  
  def test_update_as_non_comment_owner
    articles(:blog).publish!
    put :update, comments(:blog_comment).to_path.merge(:comment => { :body => 'blah blah' }), as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_update_as_commentable_owner
    articles(:blog).publish!
    put :update, comments(:blog_comment).to_path.merge(:comment => { :body => 'blah blah' }), as(:colin)
    assert_redirected_to user_blog_article_url(articles(:blog).to_path) + "#comment-#{assigns(:comment).id}"
    assert_equal "You have successfully updated #{comments(:blog_comment).display_name}.", flash[:notice]
  end
  
  def test_update_as_non_user
    articles(:blog).publish!
    put :update, comments(:blog_comment).to_path.merge(:comment => { :body => 'blah blah' })
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_destroy_as_comment_owner
    articles(:blog).publish!
    delete :destroy, comments(:blog_comment).to_path, as(:keira)
    assert_redirected_to user_blog_article_url(articles(:blog).to_path)
    assert_equal "You have deleted a comment on #{articles(:blog).display_name}.", flash[:notice]
  end
  
  def test_destroy_as_non_comment_owner
    articles(:blog).publish!
    delete :destroy, comments(:blog_comment).to_path, as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_destroy_as_commentable_owner
    articles(:blog).publish!
    delete :destroy, comments(:blog_comment).to_path, as(:colin)
    assert_redirected_to user_blog_article_url(articles(:blog).to_path)
    assert_equal "You have deleted a comment on #{articles(:blog).display_name}.", flash[:notice]
  end
end
