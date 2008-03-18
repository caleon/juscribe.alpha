module ClipsHelper
  def clip_path_for(clip, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{clip.path_name_prefix}_path(clip.to_path) }
  end
  
  def widgetable_path_for(widgetable, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{widgetable.path_name_prefix}_path(widgetable.to_path) }
  end
end
