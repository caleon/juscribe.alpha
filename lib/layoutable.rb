module Layoutable
  def layout
    self[:layout] || 'default'
  end
  
  def skin
    self[:skin] || 'default'
  end
  
  def skin_file
    "#{self.class.class_name.downcase}/" + skin
  end
end