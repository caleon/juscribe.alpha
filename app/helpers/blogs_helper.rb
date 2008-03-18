module BlogsHelper
  def blog_path_for(blog, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{blog.path_name_prefix}_path(blog.to_path) }
  end
  
  def bloggable_path_for(bloggable, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{bloggable.path_name_prefix}_path(bloggable.to_path) }
  end
end
