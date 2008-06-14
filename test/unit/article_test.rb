require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def setup
    # For some reason, since Rails 2.1 update, the instance variable does not seem to be setting.
    @sample_article = Article.create(:title => 'Testing post a6^% 8j4$9)1&!2@ lala[]', :content => 'hi hi hi 2ja z; 39fr; a893; 23;fjkdkja"]3zcv8 "', :user => users(:colin), :blog => blogs(:first))
    Article.find(:all, :conditions => "permalink IS NULL").each do |article|
      article.send(:make_permalink, :with_save => true)
    end
  end
  
  #def test_publish_and_unpublish
  #  @sample_article.publish!
  #  assert @sample_article.published?
  #  assert !@sample_article.draft?
  #  @sample_article.unpublish!
  #  assert !@sample_article.published?
  #  assert @sample_article.draft?
  #end
  
  def test_fixture_validity
    Article.find(:all).each do |article|
      assert article.valid?, article.errors.inspect
    end
  end
  
  def test_making_permalink
    #assert !@sample_article.permalink.blank?, 'Permalink column should already exist.'
    art = Article.new(:content => 'wonderful. seriously.', :user => users(:colin), :blog => blogs(:first))
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
    art = Article.create(:content => 'blah blah blah blah blah blah blah', :user => users(:colin), :title => string_with_symbols_in_front_and_back, :blog => blogs(:first))
    assert art.errors.empty?, art.errors.inspect
    assert_equal 'This-is-the-weirdest-shit-Ive-seen', art.permalink
    orig_permalink = art.permalink
    art.title = 'New title'
    assert_not_equal orig_permalink, art.permalink
    assert_equal orig_permalink, Article.find(art.id).permalink
    assert_not_equal Article.find(art.id).permalink, art.permalink
    art.save
    assert_equal Article.find(art.id).permalink, art.permalink
  end
  
  def test_to_path
    art = Article.create(:user => users(:colin), :title => 'Welcome to Maryland', :content => 'blah blah blah blah blah blah blah', :blog => blogs(:first))
    assert art.valid? && !art.new_record?
    assert_equal 'Welcome-to-Maryland', art.permalink
    assert_equal 3, art.to_path.keys.size
    assert art.to_path.keys.include?(:id)
    assert art.to_path.keys.include?(:user_id)
    assert art.to_path.keys.include?(:blog_id)
    
    art.publish!
    assert art.published? && !art.draft?
    assert_equal 6, art.to_path.keys.size
    assert_equal 6, (art.to_path.keys & [:blog_id, :year, :month, :day, :user_id, :id]).size
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
  
  
  # NOTE: P should not be an allowed tag.
  def test_formatting
    def html_escape(s)
      s.to_s.gsub(/[&"><]/) { |special| { '&' => '&amp;', '"' => '&quot;', '>' => '&gt;', '<' => '&lt;' }[special] }
    end
    alias :h :html_escape
    
    def p_wrap(text, opts={})
      allowed_tags = opts[:tags].is_a?(Array) ? opts[:tags] : %w(strong em b i code pre tt samp kbd var sub 
        sup dfn cite big small address br span h1 h2 h3 h4 h5 h6 ul ol li abbr 
        acronym a img blockquote embed object param)
      block_levels = "pre|blockquote|h1|h2|h3|h4|h5|h6|ol|ul"
      res = text.to_s.
            gsub(/(<\/?(\w+)[^>]*>)/) {|t| allowed_tags.include?($2) ? $1 : h($1)}.
            gsub(/\r\n?/, "\n").
            gsub(/\n\n+/, "</p>\n\n<p>")
      res = "<p>" + res + "</p>"
      res.gsub(/(<(?:#{block_levels})>)/, "</p>\n\\1").gsub(/(<\/(?:#{block_levels})>)/, "\\1\n<p>").
          gsub(/\s*<p><\/p>\s*/, "\n").
          gsub(/([^\n|>]\n)(?!\n)/, "\\1<br />\n").strip
    end
    
    # str.gsub(/(<p[^>]*>.*?)(?=<pre)/, '\1</p>')
    
    assert_equal "<p>Hello world</p>", p_wrap("Hello world")
    assert_equal "<p>Hello\n<br />\nworld</p>", p_wrap("Hello\nworld")
    assert_equal "<p>Hello\n<br />\nworld</p>", p_wrap("Hello\r\nworld")
    assert_equal "<p>Hello</p>\n\n<p>world</p>", p_wrap("Hello\n\nworld")
    assert_equal "<p>Hello\n<br />\nworld</p>\n\n<p>Goodbye\n<br />\nworld</p>", p_wrap("Hello\nworld\n\nGoodbye\nworld")
    assert_equal "<p>Hello\n<br />\nworld</p>\n\n<p>Goodbye\n<br />\nworld</p>", p_wrap("Hello\nworld\r\n\r\nGoodbye\r\nworld")
    assert_equal "<p>&lt;p&gt;Hello world&lt;/p&gt;</p>", p_wrap("<p>Hello world</p>")
    # Method that wraps p_wrap will use Hpricot to remove unwanted attributes
    #assert_equal "<p>&lt;p&gt;Hello world&lt;/p&gt;</p>", p_wrap('<p class="sampleClass">Hello world</p>')
    #assert_equal "<p>&lt;p&gt;Hello world&lt;/p&gt;</p>", p_wrap('<p style="color: #fff;">Hello world</p>')
    #assert_equal "<p>&lt;p&gt;Hello world&lt;/p&gt;</p>", p_wrap('<p class="sampleClass" style="color:#fff;">Hello world</p>')
    
    assert_equal "<pre>Hello world</pre>", p_wrap('<pre>Hello world</pre>')
    assert_equal "<p>Hello world</p>\n<pre>Goodbye world</pre>", p_wrap('Hello world<pre>Goodbye world</pre>')
    assert_equal "<p>Hello world </p>\n<pre>Goodbye world</pre>", p_wrap("Hello world <pre>Goodbye world</pre>")
    assert_equal "<p>Hello world\n<br />\n</p>\n<pre>Goodbye world</pre>", p_wrap("Hello world\n<pre>Goodbye world</pre>")
    assert_equal "<p>Hello world</p>\n<pre>Goodbye world</pre>", p_wrap("Hello world\n\n<pre>Goodbye world</pre>")
    assert_equal "<pre>Good morning</pre>\n<p>Good afternoon</p>\n<pre>Good evening</pre>",
                 p_wrap("<pre>Good morning</pre>Good afternoon<pre>Good evening</pre>")
    assert_equal "<p>Hello world</p>\n<pre>This is code</pre>\n<p>Goodbye world</p>",
                 p_wrap("Hello world<pre>This is code</pre>Goodbye world")
    assert_equal "<p>Hello world \n<br />\n</p>\n<pre>This is code</pre>\n<p>\n Goodbye world</p>",
                 p_wrap("Hello world\s\n<pre>This is code</pre>\n\sGoodbye world")
    
                 
    assert_equal '<pre>&lt;script type=&quot;text/javascript&quot;&gt;document.write("hello");&lt;/script&gt;</pre>',
                 p_wrap('<pre><script type="text/javascript">document.write("hello");</script></pre>') # use html_escape
                 
    
  end
end
