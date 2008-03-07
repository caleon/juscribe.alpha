# I think if within lib there were directories for each library with an init.rb
# the load path will automatically require these...
require 'plugin_package'
require 'itemizable'
ActiveRecord::Base.send(:include, Itemizable)
require 'layoutable'
require 'depictable_widget'
