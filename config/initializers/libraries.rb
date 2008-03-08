# Looks like .rb files directly within /lib will load automatically. But
# subdirectories will require naming the module/class to fit the directory
# hierarchy... for example: module ActiveRecord::Acts::Widgetable needs to be
# located at lib/active_record/acts/widgetable.rb. This will prevent needing
# to require it manually.
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Accessible)
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Itemizable)
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Responsible)
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Taggable)
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Widgetable)
require 'image_science'