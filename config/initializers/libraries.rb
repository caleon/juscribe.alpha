# require 'extensions'
require 'acts_as_layoutable'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Layoutable)
