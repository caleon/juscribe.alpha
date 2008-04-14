module TagsHelper
  # FIXME: This routing needs to be rethought. Why show a page for a tag on an object?
  def tagging_path_for(tagging, opts={})
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{tagging.path_name_prefix}_path(tagging.to_path.merge(opts[:params] || {})) }
  end
  
  def tagging_path_from_taggable(taggable, opts={})
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{taggable.path_name_prefix}_#{opts[:suffix] || 'tag'}_path(taggable.to_path(true).merge(opts[:params] || {})) }
  end
  
  def taggings_path_from_taggable(taggable, opts={})
    tagging_path_from_taggable(taggable, opts.merge(:suffix => 'tags'))
  end
  
  def taggable_path_for(taggable, opts={})
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{taggable.path_name_prefix}_path(taggable.to_path.merge(opts[:params] || {})) }
  end
end
