xml.instruct! :xml, :version => "1.0"
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title APP[:name] + ': ' + @page_title
    link_url = if @blog
      if @author.is_a?(User)
        user_blog_url(@blog.to_path)
      else
        group_blog_url(@blog.to_path)
      end
    else
      if @author.is_a?(User)
        user_url(@author)
      else
        group_url(@author)
      end
    end
    xml.link link_url
    xml.description "Latest Articles " + (@blog.nil? ? "by #{@author.display_name}" : "from #{@blog.name}")
    xml.language "en-gb"

    for article in @articles
      xml.item do
        xml.pubDate article.published_at.rfc822
        xml.title h(article.title)
        xml.link article_url_for(article)
        xml.guid article_url_for(article)
        xml.description h(article.content)
      end
    end
  end
end
