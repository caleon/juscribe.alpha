module ActiveRecord::Acts::Layoutable # included when PluginPackage is included
  # don't use this unless this module needs to add class level methods.
  # def layoutable?; true; end
  
  def layout
    #self[:layout]
    'msm'
  end
  
  def skin
    #self[:skin] || 'default'
    'msm'
  end
  
  def layout_file(file=layout)
    [ '/layouts', self.layout, self.class.class_name.pluralize.underscore, file.to_s ].join('/')
  end
  
  def skin_file
    "skins/" + skin
  end
end