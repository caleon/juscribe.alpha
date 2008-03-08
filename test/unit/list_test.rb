require File.dirname(__FILE__) + '/../test_helper'

class ListTest < ActiveSupport::TestCase
  
  def test_initial_validity
    assert lists(:normal).valid?, lists(:normal).errors.inspect
    assert lists(:gallery).valid?
    assert lists(:portfolio).valid?
    assert lists(:playlist).valid?
  end
  
  def test_validations
    list = List.create
    assert list.new_record?
    assert !list.valid?
    assert_not_nil list.errors.on(:user_id)
    assert_nil list.errors.on(:name) # Name gets dynamically set if blank.
    list.user = users(:colin)
    assert list.valid?
    assert list.save
    list.name = "   a    "
    assert !list.valid? # starts or ends with whitespace  
    list.name = "   aaa"
    assert !list.save
    list.name.strip!
    assert list.save, list.errors.inspect
  end
  
  def default_fields
    list = List.new
    assert list[:name].blank?
    assert_equal "Untitled List", list.name
  end
  
  def test_plugin_package
    assert lists(:normal).widgetable?
    assert lists(:normal).taggable?
    assert lists(:normal).responsible?
    assert lists(:normal).accessible?
  end  
  
  ### #set_itemizables tests    
  def test_normal_list
    assert_equal List, lists(:normal).class
    assert_equal 'lists', lists(:normal).class.table_name
    assert_nothing_raised(NoMethodError) { lists(:normal).items }
    assert (lists(:normal).items.descending -
            lists(:normal).items.ascending).empty?
  end
  
  def test_gallery_list
    assert_equal Gallery, lists(:gallery).class
    assert_equal 'lists', lists(:gallery).class.table_name
    assert_nothing_raised(NoMethodError) { lists(:gallery).items }
    assert_nothing_raised(NoMethodError) { lists(:gallery).pictures }
    assert_equal lists(:gallery).items, lists(:gallery).pictures
    assert (lists(:gallery).items.descending -
            lists(:gallery).items.ascending).empty?
  end
  
  def test_portfolio_list
    assert_equal Portfolio, lists(:portfolio).class
    assert_equal 'lists', lists(:portfolio).class.table_name
    assert_nothing_raised(NoMethodError) { lists(:portfolio).items }
    assert_nothing_raised(NoMethodError) { lists(:portfolio).projects }
    assert_equal lists(:portfolio).items, lists(:portfolio).projects
    assert (lists(:portfolio).items.descending -
            lists(:portfolio).items.ascending).empty?
  end
  
  def test_playlist_list
    assert_equal Playlist, lists(:playlist).class
    assert_equal 'lists', lists(:playlist).class.table_name
    assert_nothing_raised(NoMethodError) { lists(:playlist).items }
    assert_nothing_raised(NoMethodError) { lists(:playlist).songs }
    assert_equal lists(:playlist).items, lists(:playlist).songs
    assert (lists(:playlist).items.descending -
            lists(:playlist).items.ascending).empty?
  end
  
end
