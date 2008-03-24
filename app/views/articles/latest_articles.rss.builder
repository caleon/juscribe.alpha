xml.instruct! :xml, :version => "1.0"
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title APP[:name] + ': ' + @page_title
    xml.link latest_article_url_for(@author)
    xml.description "Latest articles from #{@author.display_name}"
    xml.language "en-gb"

    for article in @articles
      xml.item do
        xml.pubDate article.published_at.rfc822
        xml.title article.title
        xml.link article_path_for(article)
        xml.guid article_path_for(article)
        xml.description article.content
      end
    end
  end
end