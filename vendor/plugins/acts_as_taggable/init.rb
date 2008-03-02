$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'acts_as_taggable'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Taggable)

require 'tag'
require 'tagging'
