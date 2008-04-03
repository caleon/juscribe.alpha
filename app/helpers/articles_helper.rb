module ArticlesHelper
  def article_path_for(article, opts={})
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{article.path_name_prefix}_#{opts[:url] ? 'url' : 'path'}(article.to_path) }      
  end
  
  def article_url_for(article, opts={})
    article_path_for(article, opts.merge(:url => true))
  end
  
  def article_path_from_blog(blog, opts={})
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{blog.path_name_prefix}_article_path(blog.to_path(true)) }
  end
  
  def articles_path_from_blog(blog, opts={})
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{blog.path_name_prefix}_articles_path(blog.to_path(true)) }
  end
  
  def latest_articles_url_for(object, opts={})
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{object.path_name_prefix}_latest_articles_url(object.to_path(true)) }
  end
  
  def article_intro
    content_tag :strong, "(#{APP[:name].upcase}) --", :class => 'articleIntro'
  end
  
  def format_article(article, opts={})
    text = article.content
    text = article_intro + article.content unless opts[:without_intro]
    text = sanitize(text, :tags => %w( code blockquote pre a strong em img i b embed object ))
    text = truncate(text, opts[:truncate]) if opts[:truncate]
    simple_format text, :class => 'articleContent'
  end
end
