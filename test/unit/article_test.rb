require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def setup
    @sample_article = Article.create(:title => 'Testing post a6^% 8j4$9)1&!2@ lala[]', :content => 'hi hi hi 2ja z; 39fr; a893; 23;fjkdkja"]3zcv8 "', :user => users(:colin))
  end
  
  def test_publish_and_unpublish
    @sample_article.publish!
    assert @sample_article.published?
    assert !@sample_article.draft?
    @sample_article.unpublish!
    assert !@sample_article.published?
    assert @sample_article.draft?
  end
  
  def test_making_permalink
    assert !@sample_article.permalink.blank?, 'Permalink column should already exist.'
    art = Article.new(:content => 'wonderful. seriously.', :user => users(:colin))
    assert_nil art[:title]
    assert_nil art[:permalink]
    art.title = "generating permalinks on the fly!"
    assert_not_nil art[:title]
    assert_not_nil art.permalink
    assert art.new_record?
    assert art.save
  end
  
  def test_hash_for_path
    art = Article.create(:user => users(:colin), :title => 'Welcome to Maryland', :content => 'blah blah blah')
    assert art.valid? && !art.new_record?
    assert_equal 'Welcome-to-Maryland', art.permalink
    assert_equal 2, art.hash_for_path.keys.size
    assert art.hash_for_path.keys.include?(:permalink)
    assert art.hash_for_path.keys.include?(:nick)
    
    art.publish!
    assert art.published? && !art.draft?
    assert_equal 5, art.hash_for_path.keys.size
    assert_equal 5, (art.hash_for_path.keys & [:year, :month, :day, :nick, :permalink]).size
  end
  
  def test_find_by_nick_and_path
    path = '2008/03/10/testing-search'
    assert_nothing_raised(ArgumentError) { Article.find_by_nick_and_path('colin', path)}
    assert_nothing_raised(ActiveRecord::RecordNotFound) { Article.find_by_nick_and_path('colin', path)}
    assert_nil Article.find_by_nick_and_path('colin', path)
  end
  
  def test_find_by_path
    path = '2008/03/10/testing-search/by/colin'
    assert_nothing_raised(ArgumentError) { Article.find_by_path(path) }
    assert_nothing_raised(ActiveRecord::RecordNotFound) { Article.find_by_path(path) }
    assert_nil Article.find_by_path(path)
    
    path = '2008/03/10/testing-search/hoagie/colin'
    assert_nothing_raised(ArgumentError) { Article.find_by_path(path) }
    assert_nothing_raised(ActiveRecord::RecordNotFound) { Article.find_by_path(path) }
    assert_nil Article.find_by_path(path)
  end
  
  def test_find_by_params
    params = {'year' => '2008', 'month' => '03', 'day' => '10', 'permalink' => 'testing-search', 'nick' => 'colin'}
    assert_nothing_raised(ArgumentError) { Article.find_by_params(params) }
    assert_nothing_raised(ActiveRecord::RecordNotFound) { Article.find_by_params(params) }
    assert_nil Article.find_by_params(params)
    params = {'year' => 2008, 'month' => 03, 'day' => '10', 'permalink' => 'testing-search', 'nick' => 'colin'}
    assert_nothing_raised(ArgumentError) { Article.find_by_params(params) }
    assert_nothing_raised(ActiveRecord::RecordNotFound) { Article.find_by_params(params) }
    assert_nil Article.find_by_params(params)
  end
  
  def test_find_with_url
    user_id, year, month, day, permalink = 'colin'.hash.abs, 2008, 3, 10, 'testing-search'
    args = [user_id, year, month, day, permalink]
    assert_nothing_raised(ArgumentError) { Article.find_with_url(*args) }
    assert_nothing_raised(ActiveRecord::RecordNotFound) { Article.find_with_url(*args) }
    assert_nil Article.find_with_url(*args)
  end
  
  def test_find_by_date
    args = [2008, 3, 10]
    assert_nothing_raised(ArgumentError) { Article.find_by_date(*args) }
    assert_nothing_raised(ActiveRecord::RecordNotFound) { Article.find_by_date(*args) }
    assert_not_nil Article.find_by_date(*args)
    assert Article.find_by_date(*args).empty?
    
    args = ['2008', '03', '10']
    assert_nothing_raised(ArgumentError) { Article.find_by_date(*args) }
    assert_nothing_raised(ActiveRecord::RecordNotFound) { Article.find_by_date(*args) }
    assert_not_nil Article.find_by_date(*args)
    assert Article.find_by_date(*args).is_a?(Array)
  end
end
