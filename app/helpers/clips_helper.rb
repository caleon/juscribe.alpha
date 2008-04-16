module ClipsHelper
  def clip_path_for(clip, opts={})
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{clip.path_name_prefix}_path(clip.to_path.merge(opts[:params] || {})) }
  end
  
  def clip_path_from_widgetable(widgetable, opts={})
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{widgetable.path_name_prefix}_#{opts[:suffix] || 'clip'}_path(widgetable.to_path(true).merge(opts[:params] || {})) }
  end
  
  def clips_path_from_widgetable(widgetable, opts={})
    clip_path_from_widgetable(widgetable, opts.merge(:suffix => 'clips'))
  end
  
  def widgetable_path_for(widgetable, opts={})
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{widgetable.path_name_prefix}_path(widgetable.to_path.merge(opts[:params] || {})) }
  end
end
