module ClipsHelper
  def clip_path_for(clip, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{clip.path_name_prefix}_path(clip.to_path) }
  end
  
  def clip_path_from_widgetable(widgetable, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{widgetable.path_name_prefix}_clips_path(widgetable.to_path(true)) }
  end
  
  def widgetable_path_for(widgetable, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{widgetable.path_name_prefix}_path(widgetable.to_path) }
  end
end
