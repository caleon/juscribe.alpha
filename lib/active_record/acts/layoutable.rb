module ActiveRecord::Acts::Layoutable # included when PluginPackage is included
  # don't use this unless this module needs to add class level methods.
  # def layoutable?; true; end
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def acts_as_layoutable(options={})
      has_one :layout, :as => :layoutable
      
      include ActiveRecord::Acts::Layoutable::InstanceMethods
    end
  end
  
  module InstanceMethods
    def layout_name=(str)
      if self.layout
        self.layout.update_attribute(:name => str)
      else
        self.create_layout(:name => str, :user => self.user)
      end
    end
    
    def layout_name
      self.layout.name rescue nil
    end
  
    def layout_file(*args)
      file = args.pop
      if view_dir = args.shift
        [ '/layouts', self.layout_name, view_dir.to_s, file.to_s ].join('/')
      else
        [ '/layouts', self.layout_name, self.class.class_name.pluralize.underscore, file.to_s ].join('/')
      end
    end

    def skin_name
      self.layout.skin rescue nil
    end
  
    def skin_file
      "skins/" + skin_name if skin_name
    end
  end
end