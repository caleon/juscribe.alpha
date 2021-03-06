require File.dirname(__FILE__) + '/../test_helper'

  #Picture.class_eval do <<-EOB
  #    def content_type; "image/jpeg"; end
  #    def size; 500.kilobytes; end
  #    def filename; "some_file_name"; end
  #  EOB
  #end

class ItemTest < ActiveSupport::TestCase

  def test_initial_validity
    (Item.find(:all) + Project.find(:all) + Song.find(:all)).each do |item|
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
    [ Item, Project, Song ].each do |klass|
      assert klass.accessible?
      assert klass.widgetable?
    end
    assert items(:list_item1).accessible?
    assert items(:list_item1).widgetable?
  end
  
end
