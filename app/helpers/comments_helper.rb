module CommentsHelper
  def comment_path_for(comment, opts={})
    opts[:params] ||= {}
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{comment.path_name_prefix}_path(comment.to_path.merge(opts[:params])) }
  end
  
  def comment_path_from_commentable(commentable, opts={})
    opts[:params] ||= {}
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{commentable.path_name_prefix}_#{opts[:suffix] || 'comment'}_path(commentable.to_path(true).merge(opts[:params])) }
  end
  
  def comments_path_from_commentable(commentable, opts={})
    comment_path_from_commentable(commentable, opts.merge(:suffix => 'comments'))
  end
  
  def commentable_path_for(commentable, opts={})
    opts[:params] ||= {}
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{commentable.path_name_prefix}_path(commentable.to_path.merge(opts[:params])) }
  end
end
