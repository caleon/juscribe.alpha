require File.dirname(__FILE__) + '/../test_helper'

class ItemTest < ActiveSupport::TestCase

  def test_initial_validity
    (Item.find(:all) + Picture.find(:all) + Project.find(:all) + Song.find(:all)).each do |item|
      assert item.valid?, item.errors.inspect
    end
  end
  
  def test_validations
    item = Item.new
    assert !item.valid?
    item.user = users(:colin)
    assert !item.valid?
    item.list = lists(:normal)
    assert item.valid?
    item.name = "      a "
    assert !item.valid?
    item.name = "aa"
    assert !item.valid?
    item.name = "hungrywolf"
    assert item.valid?
    assert item.save
  end
  
  def test_default_fields
    item = Item.new
    assert item[:name].blank?
    assert_equal "Untitled Item", item.name
  end
  
  def test_plugins
    [ Item, Picture, Project, Song ].each do |klass|
      assert klass.accessible?
      assert klass.responsible?
      assert klass.taggable?
      assert klass.widgetable?
    end
    assert items(:list_item1).accessible?
    assert items(:list_item1).responsible?
    assert items(:list_item1).taggable?
    assert items(:list_item1).widgetable?
  end
  
end
