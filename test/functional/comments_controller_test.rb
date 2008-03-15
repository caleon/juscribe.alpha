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
    get :show, responses(:blog_comment).to_polypath
    assert_response :success
    assert_equal responses(:blog_comment), assigns(:comment)
  end
end
