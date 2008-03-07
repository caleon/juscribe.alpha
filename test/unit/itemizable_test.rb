require File.dirname(__FILE__) + '/../test_helper'

class ItemizingList < List
  
end

class ItemizableMixin < ActiveRecord::Base
  set_table_name "projects"
  acts_as_itemizable :itemizing_list
end

class ItemizableTest < ActiveSupport::TestCase
  
  def test_itemizable_setup
    %w( Item Picture Project Song ).each do |class_str|
      assert class_str.constantize.itemizable?
    end
    assert items(:list_item1).itemizable?
    assert pictures(:gallery_item1).itemizable?
    assert projects(:portfolio_item1).itemizable?
    assert songs(:playlist_item1).itemizable?
  end
  
  def test_pseudo_alias_associations
    assert_equal pictures(:gallery_item1).gallery, pictures(:gallery_item1).list
    assert_equal projects(:portfolio_item1).portfolio, projects(:portfolio_item1).list
    assert_equal songs(:playlist_item1).playlist, songs(:playlist_item1).list
  end
  
  def test_association_generation
    assert ItemizableMixin.itemizable?
    imix = ItemizableMixin.create
    assert imix.errors.blank?
    assert imix.itemizable?
    assert_nothing_raised(NoMethodError) { imix.itemizing_list }
    assert_nothing_raised(NoMethodError) { imix.list }
    assert_nil imix.itemizing_list
    assert_nil imix.list
    ilist = ItemizingList.create(:user => users(:colin))
    assert ilist.valid?
    assert_equal 0, ItemizableMixin.count(:conditions => "list_id = #{ilist.id}"), "id is #{ilist.id}"
    assert_equal 0, ilist.items.count
    assert_equal "lists", ItemizingList.table_name
    assert ilist.items.empty?
    assert ilist.errors.blank?
    assert_raise(NoMethodError) { ilist.itemizable_mixins }
    ItemizingList.class_eval %{ set_itemizables :itemizable_mixins }
    assert_nothing_raised(NoMethodError) { ilist.itemizable_mixins }
    imix.itemizing_list = ilist
    assert imix.save
    assert_not_nil imix.itemizing_list
    assert_not_nil imix.list
    assert_equal imix.itemizing_list, imix.list
    assert_equal 1, ilist.reload.items.size, ilist.items.map(&:inspect).inspect
    assert_equal 1, imix.position
    imix2 = ilist.itemizable_mixins.create(:name => 'diggity')
    assert_not_nil imix2.list
    assert imix2.valid?
    assert_equal 2, imix2.position
  end
  
end