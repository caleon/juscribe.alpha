require 'active_record/fixtures'

class LoadDefaultData < ActiveRecord::Migration
  def self.up
    down
    dir = File.join(File.dirname(__FILE__), 'fixtures')
    %( users groups ).each do |table|
      Fixtures.create_fixtures(dir, table)
    end
  end
  
  def self.down
    User.delete_all
    Group.delete_all
  end
end
