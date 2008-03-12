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
  
  
end
