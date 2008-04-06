module BlogsHelper
  def blog_path_for(blog, opts={})
    opts[:params] ||= {}
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{blog.path_name_prefix}_path(blog.to_path.merge(opts[:params])) }
  end
  
  def blog_path_from_bloggable(bloggable, opts={})
    opts[:params] ||= {}
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{bloggable.path_name_prefix}_#{opts[:suffix] || 'blog'}_path(bloggable.to_path(true).merge(opts[:params])) }
  end
  
  def blogs_path_from_bloggable(bloggable, opts={})
    blog_path_from_bloggable(bloggable, opts.merge(:suffix => 'blogs'))
  end
  
  def bloggable_path_for(bloggable, opts={})
    opts[:params] ||= {}
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{bloggable.path_name_prefix}_path(bloggable.to_path.merge(opts[:params])) }
  end
  
  def browse_by_month_path_for(blog, params)
    instance_eval %{ browse_by_month_#{blog.path_name_prefix}_path(blog.to_path.merge(params)) }
  end
end
