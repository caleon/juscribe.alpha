module Layoutable # included when PluginPackage is included
  # don't use this unless this module needs to add class level methods.
  # def layoutable?; true; end
  
  def layout
    self[:layout] || 'default'
  end
  
  def skin
    self[:skin] || 'default'
  end
  
  def layout_path
    "#{self.class.class_name.downcase.pluralize}/#{layout}/"
  end
  
  def layout_file
    layout_path + layout
  end
  
  def skin_file
    "#{self.class.class_name.downcase}/" + skin
  end
end