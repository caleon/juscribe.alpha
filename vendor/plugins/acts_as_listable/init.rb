$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'active_record/acts/listable'
ActiveRecord::Base.class_eval { include ActiveRecord::Acts::Listable }
