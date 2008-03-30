module ActiveRecord::Acts::Layoutable # included when PluginPackage is included
  # don't use this unless this module needs to add class level methods.
  # def layoutable?; true; end
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def acts_as_layoutable(options={})
      has_one :layouting, :as => :layoutable
            
      include ActiveRecord::Acts::Layoutable::InstanceMethods
    end
  end
  
  module InstanceMethods

  end
end