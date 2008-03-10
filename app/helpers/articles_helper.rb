module ArticlesHelper
  def show_article_path(article)
    article_path(:show, article)
  end
  
  def edit_article_path(article)
    article_path(:edit, article)
  end
  
  def article_path(action, article)
    date = article.published_date
    action = nil if action == :show
    '/' + [ date.year, sprintf("%02d", date.month), sprintf("%02d", date.day), article.to_param, action] .compact.join('/')
  end
end
