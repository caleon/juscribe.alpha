$:.unshift "#{File.dirname(__FILE__)}/lib"

#require "#{File.dirname(__FILE__)}/../acts_as_list/init"
#ActiveRecord::Base.class_eval { include ActiveRecord::Acts::List }

require 'acts_as_widgetable'
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Widgetable)

require 'widget'
