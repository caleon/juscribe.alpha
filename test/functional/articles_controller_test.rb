require File.dirname(__FILE__) + '/../test_helper'

class ArticlesControllerTest < ActionController::TestCase
  
  def test_index
    Article.find(:all).each do |art|
      art.send(:make_permalink)
      art.publish!
    end
    get :index, { :blog_id => blogs(:first).to_param, :user_id => blogs(:first).user.to_param }
    assert_response :success
    assert_equal users(:colin), assigns(:author)
    assert_equal users(:colin).articles.find(:all, :order => 'id DESC'), assigns(:articles)
    assigns(:articles).each do |art|
      assert art.is_a?(Article), "art is actually #{art.class}"
      assert art.valid?, art.errors.inspect
      assert_nothing_raised(NoMethodError) { art.user; art.title; art.to_path }
      assert_equal users(:colin), art.user
    end
  end
  
  def test_index_with_invalid_nick
    get :index, blogs(:first).to_path(true).merge(:user_id => 'colina')
    assert_template 'error'
    assert_flash_equal 'That blog could not be found. Please check the address.', :warning
  end
  
  def test_list
    # TODO
  end
  
  def test_show_with_fully_formed_url
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    date = articles(:blog).published_date
    assert_not_nil articles(:blog).published_date
    get :show, { :blog_id => blogs(:first).to_param, :year => sprintf("%02d", date.year), :month => sprintf("%02d", date.month), :day => sprintf("%02d", date.day), :id => articles(:blog).permalink, :user_id => articles(:blog).user.nick }
    assert_response :success
    assert_equal articles(:blog), assigns(:article)
  end
  
  def test_new_without_nick
    assert_raise(ActionController::RoutingError) { get :new }
  end
  
  def test_new_without_login
    get :new, users(:colin).to_path(true).merge(blogs(:first).to_path(true))
    assert_redirected_to login_url
    assert_equal 'You need to be logged in to do that.', flash[:warning]
  end
 
  def test_new_with_login
    get :new, users(:colin).to_path(true).merge(blogs(:first).to_path(true)), as(:colin)
    assert_response :success
  end
  
  def test_new_for_someone_else
    get :new, blogs(:first).to_path(true).merge(users(:nana).to_path(true)), as(:colin)
    assert_template 'error'
    assert_flash_equal "That blog could not be found. Please check the address.", :warning
  end
  
  def test_new_with_wrong_nick
    get :new, { :user_id => 'colina', :blog_id => blogs(:first).to_param }, as(:colin)
    assert_template 'error'
    assert_flash_equal "That blog could not be found. Please check the address.", :warning
  end
  
  def test_create
    post :create, { :article => { :title => "Blah blahdy la la la", :content => "dum dum dum dum dum", :publish => "1", :blog_id => blogs(:first).id }, :user_id => 'colin', :blog_id => blogs(:first).to_param }, as(:colin)
    article = Article.find(:first, :order => 'id DESC', :conditions => ["title = ?", "Blah blahdy la la la"])
    assert article.valid?
    assert_redirected_to user_blog_article_url(article.to_path)
    assert_equal "You have successfully created your article.", flash[:notice]
  end
  
  def test_create_without_login
    post :create, { :article => { :title => "Blah blahdy la la la", :content => "dum dum dum", :blog_id => blogs(:first).id }, :user_id => 'colin', :blog_id => blogs(:first).to_param }
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_create_with_error
    post :create, { :article => { :title => "", :content => "dum dum dum", :blog_id => blogs(:first).id }, :user_id => 'colin', :blog_id => blogs(:first).to_param }, as(:colin)
    assert_not_nil assigns(:article)
    assert !assigns(:article).valid?
    assert_flash_equal "There was an error creating your article.", :warning
  end
  
  def test_create_with_picture
    post :create, { :article => { :title => "this is a picture post", :content => "dum dum dum dum dum dum dum", :publish => "1", :blog_id => 'first'.hash.abs }, :picture => { :uploaded_data => fixture_file_upload("yuri.jpg", "image/jpg") }, :user_id => 'colin', :blog_id => blogs(:first).to_param }, as(:colin)
    article = Article.find_by_title('this is a picture post')
    assert_not_nil article[:permalink]
    assert article.valid?
    assert_redirected_to user_blog_article_url(article.to_path)
    assert_equal "You have successfully created your article.", flash[:notice]
  end
  
  def test_edit
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    get :edit, articles(:blog).to_path, as(:colin)
    assert_response :success
    assert_equal users(:colin), articles(:blog).user
    assert_template 'edit'
    assert_equal articles(:blog), assigns(:article)
  end
  
  def test_edit_without_login
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    get :edit, articles(:blog).to_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_edit_without_ownership
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    get :edit, articles(:blog).to_path, as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_edit_invalid_article
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    date = articles(:blog).published_date
    get :edit, { :id => articles(:blog).permalink.chop, :user_id => articles(:blog).user.nick, :blog_id => articles(:blog).blog.to_param, :year => date.year.to_s, :month => sprintf("%02d", date.month), :day => sprintf("%02d", date.day) }, as(:colin)
    assert_flash_equal 'That article could not be found. Please check the address.', :warning
  end
  
  def test_update
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    date = articles(:blog).published_date
    put :update, articles(:blog).to_path.update(:article => { :title => 'yo yo yo' }), as(:colin)
    assert_redirected_to articles(:blog).reload.to_path
    assert_equal "You have successfully updated #{articles(:blog).display_name}.", flash[:notice]
    assert_equal articles(:blog), assigns(:article)
  end
  
  def test_update_without_login
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    date = articles(:blog).published_date
    put :update, articles(:blog).to_path.update(:article => { :title => 'yo yo yo' })
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_update_with_wrong_user
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    date = articles(:blog).published_date
    put :update, articles(:blog).to_path.update(:article => { :title => 'yo yo yo' }), as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_update_with_non_user
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    date = articles(:blog).published_date
    put :update, articles(:blog).to_path.update(:article => { :title => 'yo yo yo' }), as(234234)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_update_with_invalid_entries
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    date = articles(:blog).published_date
    put :update, articles(:blog).to_path.update(:article => { :content => ' ' }), as(:colin)
    assert_template 'edit'
    assert_flash_equal 'There was an error updating your article.', :warning
  end
  
  def test_unpublish
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    put :unpublish, articles(:blog).to_path, as(:colin)
    assert_redirected_to user_blog_draft_url(articles(:blog).reload.to_path)
    assert_equal "You have unpublished #{articles(:blog).display_name}.", flash[:notice]
  end
  
  def test_unpublish_unpublished
    assert_raise(ActionController::RoutingError) { put :unpublish, articles(:blog).to_path, as(:colin) }
  end
  
  def test_destroy
    @request.env["HTTP_REFERER"] = "http://www.cnn.com/"
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    delete :destroy, articles(:blog).to_path, as(:colin)
    assert_response :redirect
    assert_redirected_to 'http://www.cnn.com'
    assert_equal "You have deleted #{articles(:blog).display_name}.", flash[:notice]
  end
  
  def test_destroy_without_login
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    date = articles(:blog).published_date
    delete :destroy, articles(:blog).to_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  ### DRAFTS
  
  def test_draft_edit
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    get :edit, articles(:blog).to_path, as(:colin)
    assert_response :success
    assert_template 'edit', articles(:blog).to_path.inspect
  end
  
  def test_draft_edit_with_wrong_permalink
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    get :edit, articles(:blog).to_path.update(:id => articles(:blog).permalink.chop), as(:colin)
    assert_template 'error'
    assert_flash_equal 'That article could not be found. Please check the address.', :warning
  end
  
  def test_draft_edit_with_wrong_nick
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    get :edit, articles(:blog).to_path.update(:user_id => articles(:blog).user.nick.chop), as(:colin)
    assert_template 'error'
    assert_flash_equal 'That blog could not be found. Please check the address.', :warning
  end
  
  def test_draft_edit_without_login
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    get :edit, articles(:blog).to_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_draft_edit_with_wrong_user
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    get :edit, articles(:blog).to_path, as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_draft_edit_with_non_user
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    get :edit, articles(:blog).to_path, as(12345567)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_draft_show
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    get :show, articles(:blog).to_path, as(:colin)
    assert_response :success
    assert_template 'show', articles(:blog).to_path.inspect
  end
  
  def test_draft_show_with_only_permalink
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    assert_raise(ActionController::RoutingError) { get :show, { :id => articles(:blog).permalink }, as(:colin) }
  end
  
  def test_draft_show_with_wrong_permalink
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    get :show, articles(:blog).to_path.update(:id => articles(:blog).permalink.chop), as(:colin)
    assert_template 'error'
    assert_flash_equal 'That article could not be found. Please check the address.', :warning
  end
  
  def test_draft_show_with_wrong_nick
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    get :show, articles(:blog).to_path.update(:user_id => articles(:blog).user.nick.chop), as(:colin)
    assert_template 'error'
    assert_flash_equal 'That blog could not be found. Please check the address.', :warning
  end
  
  def test_draft_show_without_login
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    get :show, articles(:blog).to_path
    assert_redirected_to login_url
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_draft_show_with_wrong_user
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    get :show, articles(:blog).to_path, as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_draft_show_with_non_user
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    get :show, articles(:blog).to_path, as(123456677)
    assert_redirected_to login_url
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_draft_update
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    put :update, articles(:blog).to_path.merge(:article => { :content => "la dee la la dee la" }), as(:colin)
    assert_redirected_to user_blog_draft_url(articles(:blog).to_path)
    assert_equal "You have successfully updated #{articles(:blog).display_name}.", flash[:notice]
  end
  
  def test_draft_update_with_title_change
    new_title = "This is a new title."
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    put :update, articles(:blog).to_path.merge(:article => { :title => new_title }), as(:colin)
    assert_redirected_to user_blog_draft_url(articles(:blog).to_path)
    assert_equal "You have successfully updated #{articles(:blog).display_name}.", flash[:notice]
    assert_not_equal new_title, articles(:blog).reload.title
  end
  
  def test_draft_update_with_wrong_permalink
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    put :update, articles(:blog).to_path.merge(:article => { :content => "la dee la" }, :id => articles(:blog).permalink.chop), as(:colin)
    assert_template 'error'
    assert_flash_equal 'That article could not be found. Please check the address.', :warning
  end
  
  def test_draft_update_with_wrong_nick
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    put :update, articles(:blog).to_path.merge(:article => { :content => 'la dee la' }, :user_id => articles(:blog).user.nick.chop), as(:colin)
    assert_template 'error'
    assert_flash_equal 'That blog could not be found. Please check the address.', :warning
  end
  
  def test_draft_update_without_login
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    put :update, articles(:blog).to_path.merge(:article => { :content => "la dee la" })
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_draft_update_with_wrong_user # TODO: test the attr protected stuff. Make sure title uneditab.
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    assert !articles(:blog).published?
    assert !articles(:blog).editable_by?(users(:nana))
    put :update, articles(:blog).to_path.merge(:article => { :content => "la dee la" }), as(:nana)
    assert_not_nil assigns(:blog)
    assert_not_nil assigns(:author)
    assert_not_nil assigns(:article)
    assert_equal articles(:blog), assigns(:article)
    assert !assigns(:article).reload.accessible_by?(users(:nana))
    assert !assigns(:article).editable_by?(users(:nana))
    assert_redirected_to user_url(users(:nana))
    assert_equal 'You are not authorized for that action.', flash[:warning]
  end
  
  def test_draft_update_with_non_user
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    put :update, articles(:blog).to_path.merge(:article => { :content => "la dee la" }), as(1234556677)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_draft_publish
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    assert articles(:blog).to_path.keys.size == 3 # nick and permalink AND blog_id
    put :publish, articles(:blog).to_path, as(:colin)
    assert_redirected_to user_blog_article_url(articles(:blog).reload.to_path)
    assert_equal "You have published #{articles(:blog).display_name}.", flash[:notice]
  end
  
  def test_draft_publish_with_wrong_permalink
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    put :publish, articles(:blog).to_path.merge(:id => articles(:blog).permalink.chop), as(:colin)
    assert_template 'error'
    assert_flash_equal "That article could not be found. Please check the address.", :warning
  end
  
  def test_draft_publish_with_wrong_nick
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    put :publish, articles(:blog).to_path.merge(:user_id => articles(:blog).user.nick.chop), as(:colin)
    assert_template 'error'
    assert_flash_equal "That blog could not be found. Please check the address.", :warning
  end
  
  def test_draft_publish_without_login
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    put :publish, articles(:blog).to_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_draft_publish_with_wrong_user
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    assert_not_nil articles(:blog)[:permalink]
    put :publish, articles(:blog).to_path, as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_draft_publish_with_non_user
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    put :publish, articles(:blog).to_path, as(1234566)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_draft_destroy
    @request.env["HTTP_REFERER"] = "http://www.cnn.com/"
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    delete :destroy, articles(:blog).to_path, as(:colin)
    assert_response :redirect
    assert_equal "You have deleted #{articles(:blog).display_name}.", flash[:notice]
    assert_redirected_to 'http://www.cnn.com'
  end
  
  def test_draft_destroy_without_login
    @request.env["HTTP_REFERER"] = "http://www.cnn.com/"
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    delete :destroy, articles(:blog).to_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_draft_destroy_with_wrong_user
    @request.env["HTTP_REFERER"] = "http://www.cnn.com/"
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    delete :destroy, articles(:blog).to_path, as(:nana)
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_draft_destroy_with_non_user
    @request.env["HTTP_REFERER"] = "http://www.cnn.com/"
    articles(:blog).send(:make_permalink, :with_save => true)
    assert articles(:blog).draft?
    delete :destroy, articles(:blog).to_path, as(12344556)
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
end
