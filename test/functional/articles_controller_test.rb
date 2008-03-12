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
  
  def test_show
    
  end
  
  
end
