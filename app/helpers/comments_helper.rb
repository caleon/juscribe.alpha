module CommentsHelper
  def comment_path_for(comment, opts={})
    if opts[:anchor]
      commentable_path_for(comment.commentable, opts) + "#comment-#{comment.scoped_id}"
    else
      instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{comment.path_name_prefix}_path(comment.to_path.merge(opts[:params] || {})) }
    end
  end
  
  def comment_url_for(comment, opts={})
    "http://www.juscribe.com" + comment_path_for(comment, opts)
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
  
  def commenter_for(comment)
    return nil unless comment
    if comment.anonymous?
      comment.nick
    else
      link_to comment.user.display_name, user_path(comment.user)
    end
  end
  
  # Borrows heavily from articles_helper.rb
  def format_comment(comment, opts={})
    opts[:comment] ||= comment
    text = escape_code_html(comment.body.blank? ? '[Deleted]' : comment.body)
    formatted = Hpricot(p_wrap(text))
    clean_code_breaks(formatted)
    clarify_external_links(formatted)
    text = sanitize(formatted.to_html, :tags => allowed_tags(opts[:truncate]), :attributes => allowed_attributes)
    hpricot = Hpricot(text)
    hpricot.each_child do |child|
      child.set_attribute('class', opts[:class] || 'commentContent') if child.elem?
    end    
    opts[:truncate] ? truncate_html(hpricot.to_s, opts[:truncate]) : hpricot.to_s
  end
  
  def block_wrap(text, opts={})
    wrapper = opts[:tag] || 'div'
    # Actually if opts[:truncate], we might wanna remove the bad tags entirely instead of escaping...
    my_allowed_tags = opts[:tags].is_a?(Array) ? opts[:tags] : (allowed_tags - [wrapper])
    # Basically these are types that cannot exist within a P tag. P is not allowed, however.
    # TODO: Style h1-h3 so that they are at greatest the size of an h3.
    block_levels = "pre|blockquote|h1|h2|h3|h4|h5|h6|ol|ul"
    res = text.to_s.
          gsub(/(<\/?(\w+)[^>]*>)/) {|t| my_allowed_tags.include?($2) ? $1 : h($1)}.
          gsub(/\r\n?/, "\n").
          gsub(/\n\n+/, "</p>\n\n<p>")
    res = "<div>" + res + "</div>"

    res.gsub(/(<(?:#{block_levels})>)/, "</p>\n\\1").gsub(/(<\/(?:#{block_levels})>)/, "\\1\n<p>").
        gsub(/\s*<p><\/p>\s*/, "\n").
        gsub(/([^\n|>]\n)(?!\n)/, "\\1<br />\n").strip
    
  end
  
end
