module ArticlesHelper
  def article_path_for(article)
    if article.published?
      article_path(article.hash_for_path)
    else
      draft_path(article.hash_for_path)      
    end
  end
end
