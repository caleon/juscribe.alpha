module ArticlesHelper
  def article_path_for(article, opts={})
    if article.published?
      instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}article_path(article.to_path) }
    else
      instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}draft_path(article.to_path) }      
    end
  end
  
  def article_intro
    content_tag :strong, "(#{APP[:name].upcase}) --", :class => 'articleIntro'
  end
  
  def format_article(article, opts={})
    text = article.content
    text = article_intro + article.content unless opts[:without_intro]
    text = sanitize(text, :tags => %w( code blockquote a strong em img i b embed object ))
    text = truncate(text, opts[:truncate]) if opts[:truncate]
    simple_format text, :class => 'articleContent'
  end
end
