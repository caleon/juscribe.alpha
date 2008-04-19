xml.instruct! :xml, :version => "1.0"
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title APP[:name] + ': ' + @page_title
    link_url = @bloggable.is_a?(User) ? user_blog_url(@blog.to_path) : group_blog_url(@blog.to_path)
    xml.link link_url
    xml.description "Latest Articles from #{@blog.name}"
    xml.language "en-gb"

    for article in @articles
      xml.item do
        xml.pubDate article.published? ? article.published_at.rfc822 : article.created_at.rfc822
        xml.title h(article.title)
        xml.link article_url_for(article)
        xml.guid article_url_for(article)
        xml.description article.content
      end
    end
  end
end
