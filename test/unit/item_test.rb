require File.dirname(__FILE__) + '/../test_helper'

class ItemTest < ActiveSupport::TestCase

  def test_initial_validity
    (Item.find(:all) + Picture.find(:all) + Project.find(:all) + Song.find(:all)).each do |item|
      assert item.valid?, item.errors.inspect
    end
  end
  
  
end
