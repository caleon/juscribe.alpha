require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def setup
    @sample_article = Article.create(:title => 'Testing post a6^% 8j4$9)1&!2@ lala[]', :content => 'hi hi hi 2ja z; 39fr; a893; 23;fjkdkja"]3zcv8 "', :user => users(:colin))
  end
  
  def test_publish_and_unpublish
    @sample_article.publish!
    assert @sample_article.published?
    @sample_article.unpublish!
    assert !@sample_article.published?
  end
  
  def test_making_permalink
    assert !@sample_article.permalink.blank?, 'Permalink column should already exist.'
  end
  
  def test_custom_finds
    # TODO: stubbed
  end
end
