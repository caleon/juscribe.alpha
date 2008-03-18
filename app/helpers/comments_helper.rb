module CommentsHelper
  def comment_path_for(comment, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{comment.path_name_prefix}_path(comment.to_path) }
  end
  
  def commentable_path_for(commentable, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{commentable.path_name_prefix}_path(commentable.to_path) }
  end
end
