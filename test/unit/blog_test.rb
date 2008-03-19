require File.dirname(__FILE__) + '/../test_helper'

class BlogTest < ActiveSupport::TestCase

  def test_basics
    assert blogs(:first).valid?
    assert_equal blogs(:first).short_name.gsub(/['"]+/i, '').gsub(/[^a-z0-9]+/i, '-').gsub(/-{2,}/, '-').gsub(/^-/, '').gsub(/-$/, '').upcase, blogs(:first).permalink
    assert_equal blogs(:first).permalink, blogs(:first).to_param
    assert_not_nil blogs(:first).bloggable
    assert_equal users(:colin), blogs(:first).bloggable
    expected_hash = { :id => blogs(:first).to_param, :user_id => users(:colin).to_param }
    assert_equal expected_hash, blogs(:first).to_path
  end
  
  def test_basics_on_new_blog
    blog = Blog.new
    blog.name = "Testing blog name"
    blog.short_name = "Testing"
    assert_not_nil blog[:permalink]
    assert_equal "TESTING", blog[:permalink]
    assert !blog.valid?
    blog.bloggable = users(:colin)
    assert blog.valid?
  end
  
  def test_blog_widget_content_formatting
    # TODO: finalize this when model method is finalized.
  end
end
