require File.dirname(__FILE__) + '/../test_helper'

class ArticlesControllerTest < ActionController::TestCase
  
  def test_index
    Article.find(:all).each do |art|
      art.send(:make_permalink, :with_save => true)
    end
    get :index, { :nick => 'colin' }
    assert_response :success
    assert_equal users(:colin), assigns(:user)
    assert_equal users(:colin).articles.find(:all, :order => 'id DESC'), assigns(:articles)
    assigns(:articles).each do |art|
      assert art.is_a?(Article), "art is actually #{art.class}"
      assert art.valid?, art.errors.inspect
      assert_nothing_raised(NoMethodError) { art.user; art.title; art.hash_for_path }
      assert_equal users(:colin), art.user
    end
  end
  
  def test_index_with_invalid_nick
    get :index, { :nick => 'colina' }
    assert_template 'error'
    assert_flash_equal 'That user could not be found.', :warning
  end
  
  def test_list
    # TODO
  end
  
  def test_show_with_fully_formed_url
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    date = articles(:blog).published_date
    get :show, { :year => sprintf("%02d", date.year), :month => sprintf("%02d", date.month), :day => sprintf("%02d", date.day), :permalink => articles(:blog).permalink, :nick => articles(:blog).user.nick }
    assert_response :success
    assert_equal articles(:blog), assigns(:article)
  end
  
  def test_show_with_single_digit_dates
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    date = articles(:blog).published_date
    get :show, { :year => date.year, :month => date.month, :day => date.day, :permalink => articles(:blog).permalink, :nick => articles(:blog).user.nick }
    assert_response 301
    assert_equal articles(:blog), assigns(:article)
    assert_equal "http://test.host/#{date.year}/#{sprintf("%02d", date.month)}/#{sprintf("%02d", date.day)}/Today-was-a-really-weird-day/by/colin",
                 redirect_to_url
  end
  
  def test_show_with_only_permalink_and_nick
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    date = articles(:blog).published_date
    get :show, { :permalink => articles(:blog).permalink, :nick => articles(:blog).user.nick }
    assert_response 303
    assert_redirected_to articles(:blog).hash_for_path
    assert_equal "http://test.host/#{date.year}/#{sprintf("%02d", date.month)}/#{sprintf("%02d", date.day)}/Today-was-a-really-weird-day/by/colin",
                 redirect_to_url
  end
  
  def test_show_with_only_permalink
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    date = articles(:blog).published_date
    get :show, { :permalink => articles(:blog).permalink }
    assert_response 303
    assert_redirected_to articles(:blog).hash_for_path
    assert_equal "http://test.host/#{date.year}/#{sprintf("%02d", date.month)}/#{sprintf("%02d", date.day)}/Today-was-a-really-weird-day/by/colin",
                 redirect_to_url
  end
    
  def test_show_with_only_permalink_but_with_multiple_matches
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    date = articles(:blog).published_date
    art2 = Article.create(:title => articles(:blog).title, :content => articles(:opinion).content, :user => users(:nana))
    assert_not_nil art2[:permalink]
    assert_equal art2.permalink, articles(:blog).permalink
    art2.publish!
    
    get :show, { :permalink => articles(:blog).permalink }
    assert :success
    assert_flash_equal "Multiple articles were found with that address.", :warning
  end
  
  def test_new_without_nick
    assert_raise(ActionController::RoutingError) { get :new }
  end
  
  def test_new_without_login
    get :new, { :nick => 'colin' }
    assert_redirected_to login_url
    assert_equal 'You need to be logged in to do that.', flash[:warning]
  end
 
  def test_new_with_login
    get :new, { :nick => 'colin' }, { :user_id => users(:colin).id }
    assert_response :success
  end
  
  def test_new_for_someone_else
    get :new, { :nick => 'nana' }, { :user_id => users(:colin).id }
    assert_redirected_to new_article_url(users(:colin))
  end
  
  def test_new_with_wrong_nick
    get :new, { :nick => 'colina' }, { :user_id => users(:colin).id }
    assert_template 'error'
    assert_flash_equal "That User could not be found. Please check your address.", :warning
  end
  
  def test_create
    post :create, { :article => { :title => "Blah blahdy la la la", :content => "dum dum dum dum dum" } }, { :user_id => users(:colin).id }
    article = Article.find(:first, :order => 'id DESC', :conditions => ["title = ?", "Blah blahdy la la la"])
    assert article.valid?
    assert_redirected_to article.hash_for_path
    assert_equal "You have successfully created your article.", flash[:notice]
  end
  
  def test_create_without_login
    post :create, { :article => { :title => "Blah blahdy la la la", :content => "dum dum dum" } }
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_create_with_error
    post :create, { :article => { :title => "", :content => "dum dum dum"} }, { :user_id => users(:colin).id }
    assert_not_nil assigns(:article)
    assert !assigns(:article).valid?
    assert_flash_equal "There was an error creating your article.", :warning
  end
  
  def test_create_with_picture
    post :create, { :article => { :title => "this is a picture post", :content => "dum dum dum dum dum dum dum"}, :picture => { :uploaded_data => fixture_file_upload("yuri.jpg", "image/jpg") } }, { :user_id => users(:colin).id }
    article = Article.find_by_title('this is a picture post')
    assert_not_nil article[:permalink]
    assert article.valid?
    assert_redirected_to article.hash_for_path
    assert_equal "You have successfully created your article.", flash[:notice]
  end
  
  def test_edit
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    get :edit, articles(:blog).hash_for_path, { :user_id => users(:colin).id }
    assert_response :success
    assert_equal users(:colin), articles(:blog).user
    assert_template 'edit'
    assert_equal articles(:blog), assigns(:article)
  end
  
  def test_edit_without_login
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    get :edit, articles(:blog).hash_for_path
    assert_redirected_to login_url
    assert_equal "You need to be logged in to do that.", flash[:warning]
  end
  
  def test_edit_without_ownership
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    get :edit, articles(:blog).hash_for_path, { :user_id => users(:nana).id }
    assert_redirected_to user_url(users(:nana))
    assert_equal "You are not authorized for that action.", flash[:warning]
  end
  
  def test_edit_invalid_article
    articles(:blog).send(:make_permalink)
    articles(:blog).publish!
    date = articles(:blog).published_date
    get :edit, { :permalink => articles(:blog).permalink.chop, :nick => articles(:blog).user.nick, :year => date.year.to_s, :month => sprintf("%02d", date.month), :day => sprintf("%02d", date.day) }, { :user_id => users(:colin).id }
    assert_flash_equal 'That article could not be found. Please check the address.', :warning
  end
end
