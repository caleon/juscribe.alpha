$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'acts_as_accessible'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Accessible)

require 'permission'
require 'permission_rule'