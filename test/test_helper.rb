ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

require 'test_help'

class ActionController::Resources::Resource #:nodoc:
  def path; @path ||= @options[:special_path] || "#{path_prefix}/#{@options[:custom_path] || plural}"; end
end

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  # FIXME: This fails when used in conjunction with #flash_name_for. The html will display with
  # backslashes in the error for the test but in actually it probably doesn't. On the other hand,
  # assert_tag seems to be escaping characters on its own
  def assert_flash_equal(expects, type)
    assert_tag :tag => 'div', :attributes => { :id => "flash#{type.to_s.capitalize}" },
                              :content => expects
  end
  
  def assert_flash_exists(type)
    assert_tag :tag => 'div', :attributes => { :id => "flash#{type.to_s.capitalize}" }
  end
  
  def as(*args)
    opts = args.extract_options!
    hash = { :id => nil }
    case arg = args.shift
    when Symbol
      hash[:id] = users(arg).id
    when Fixnum
      hash[:id] = arg
    when User
      hash[:id] = arg.id
    else
      nil
    end
    hash.merge(opts)
    hash
  end
  
  def flash_name_for(record)
    %{<span class="recordName #{record.class.class_name.underscore}Name">#{record.display_name}</span>}
  end
end
