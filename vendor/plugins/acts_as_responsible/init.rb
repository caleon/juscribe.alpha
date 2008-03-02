$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'acts_as_responsible'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Responsible)

require 'response'
require 'favorite'
require 'rating'
require 'report'
require 'comment'
