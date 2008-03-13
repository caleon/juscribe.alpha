require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def setup
    @sample_article = Article.create(:title => 'Testing post a6^% 8j4$9)1&!2@ lala[]', :content => 'hi hi hi 2ja z; 39fr; a893; 23;fjkdkja"]3zcv8 "', :user => users(:colin))
    Article.find(:all, :conditions => "permalink IS NULL").each do |article|
      article.send(:make_permalink, :with_save => true)
    end
  end
  
  def test_publish_and_unpublish
    @sample_article.publish!
    assert @sample_article.published?
    assert !@sample_article.draft?
    @sample_article.unpublish!
    assert !@sample_article.published?
    assert @sample_article.draft?
  end
  
  def test_fixture_validity
    Article.find(:all).each do |article|
      assert article.valid?, article.errors.inspect
    end
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
    
    string_with_weird_characters = '3421#$951asjdfeaj 343 41#4  asdf#'
    assert art = Article.create(:content => 'blah blah', :user => users(:colin), :title => string_with_weird_characters)
    assert_equal '3421-951asjdfeaj-343-41-4-asdf', art.permalink
    
    string_with_symbols_in_front_and_back = '!!! This is the weirdest shit I\'ve seen!'
    assert art = Article.create(:content => 'blah blah', :user => users(:colin), :title => string_with_symbols_in_front_and_back)
    assert_equal 'This-is-the-weirdest-shit-Ive-seen', art.permalink
    orig_permalink = art.permalink
    art.title = 'New title'
    assert_not_equal orig_permalink, art.permalink
    assert_equal orig_permalink, Article.find(art.id).permalink
    assert_not_equal Article.find(art.id).permalink, art.permalink
    art.save
    assert_equal Article.find(art.id).permalink, art.permalink
  end
  
  def test_hash_for_path
    art = Article.create(:user => users(:colin), :title => 'Welcome to Maryland', :content => 'blah blah blah')
    assert art.valid? && !art.new_record?
    assert_equal 'Welcome-to-Maryland', art.permalink
    assert_equal 2, art.hash_for_path.keys.size
    assert art.hash_for_path.keys.include?(:permalink)
    assert art.hash_for_path.keys.include?(:user_id)
    
    art.publish!
    assert art.published? && !art.draft?
    assert_equal 5, art.hash_for_path.keys.size
    assert_equal 5, (art.hash_for_path.keys & [:year, :month, :day, :user_id, :permalink]).size
  end
  
  def test_find_by_params
    params = {'year' => '2008', 'month' => '03', 'day' => '10', 'permalink' => 'testing-search', 'user_id' => 'colin'}
    assert_nothing_raised(ArgumentError) { Article.find_by_params(params) }
    assert_nothing_raised(ActiveRecord::RecordNotFound) { Article.find_by_params(params) }
    assert_nil Article.find_by_params(params)
    params = {'year' => 2008, 'month' => 03, 'day' => '10', 'permalink' => 'testing-search', 'user_id' => 'colin'}
    assert_nothing_raised(ArgumentError) { Article.find_by_params(params) }
    assert_nothing_raised(ActiveRecord::RecordNotFound) { Article.find_by_params(params) }
    assert_nil Article.find_by_params(params)
  end
  
  def test_find_any_by_permalink_and_nick
    args = ['testing-search', 'colin']
    assert_nothing_raised(ArgumentError) { Article.find_any_by_permalink_and_nick(*args) }
    assert_nothing_raised(ActiveRecord::RecordNotFound) { Article.find_any_by_permalink_and_nick(*args) }
    assert_not_nil Article.find_any_by_permalink_and_nick(*args)
    assert Article.find_any_by_permalink_and_nick(*args).empty?
  end
end
