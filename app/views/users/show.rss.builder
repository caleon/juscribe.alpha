xml.instruct! :xml, :version => "1.0"
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title APP[:name] + ': ' + @page_title
    xml.link user_url(@user)
    xml.description "#{@user.nick}'s Blogs"
    xml.language "en-gb"

    for article in @user.articles
      xml.item do
        xml.pubDate article.published_at.rfc822
        xml.title h(article.title)
        xml.link article_url_for(article)
        xml.guid article_url_for(article)
        xml.description article.content
      end
    end
  end
end
