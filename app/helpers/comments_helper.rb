module CommentsHelper
  def comment_path_for(comment, opts={})
#    path = instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{comment.path_name_prefix}_path(comment.to_path.merge(opts[:params])) }
    commentable_path_for(comment.commentable, opts) + "#comment-#{comment.scoped_id}"
  end
  
  def comment_path_from_commentable(commentable, opts={})
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{commentable.path_name_prefix}_#{opts[:suffix] || 'comment'}_path(commentable.to_path(true).merge(opts[:params] || {})) }
  end
  
  def comments_path_from_commentable(commentable, opts={})
    comment_path_from_commentable(commentable, opts.merge(:suffix => 'comments'))
  end
  
  def commentable_path_for(commentable, opts={})
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{commentable.path_name_prefix}_path(commentable.to_path.merge(opts[:params] || {})) }
  end
  
  def comment_form_for(record, opts={})
    render :partial => 'comments/form', :locals => { :commentable => record }
  end
  
  # Borrows heavily from articles_helper.rb
  def format_comment(comment, opts={})
    opts[:comment] ||= comment
    text = comment.body
    formatted = Hpricot(p_wrap(text))
    escape_code_html(formatted)
    clarify_external_links(formatted)
    text = sanitize(formatted.to_html, :tags => allowed_tags(opts[:truncate]), :attributes => allowed_attributes)
    hpricot = Hpricot(text)
    hpricot.each_child do |child|
      child.set_attribute('class', opts[:class] || 'commentContent') if child.elem?
    end    
    opts[:truncate] ? truncate_html(hpricot.to_s, opts[:truncate]) : hpricot.to_s
  end
  
end
