require 'plugin_package'
require 'itemizable'
ActiveRecord::Base.send(:include, Itemizable)
require 'layoutable'
require 'depictable_widget'
