module ArticlesHelper
  def article_path_for(article)
    if article.published?
      article_path(article.to_path)
    else
      draft_path(article.to_path)      
    end
  end
end
