module ActiveRecord::Acts::Layoutable # included when PluginPackage is included
  # don't use this unless this module needs to add class level methods.
  # def layoutable?; true; end
  
  def layout
    self[:layout] || 'default'
  end
  
  def skin
    self[:skin] || 'default'
  end
  
  def layout_file(file=layout)
    [ '/layouts', self.layout, self.class.class_name.pluralize.underscore, file.to_s ].join('/')
  end
  
  def skin_file
    "#{self.class.class_name.underscore.pluralize}/" + skin
  end
end