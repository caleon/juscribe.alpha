xml.instruct! :xml, :version => "1.0"
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title APP[:name] + ': ' + @page_title
    xml.link user_thoughtlets_url(@user)
    xml.description "Latest thoughtlets from #{@user.display_name}"
    xml.language "en-gb"

    for thoughtlet in @thoughtlets
      xml.item do
        xml.pubDate thoughtlet.created_at.rfc822
        xml.title truncate(h(thoughtlet.content), 50)
        xml.link user_thoughtlet_url(thoughtlet.to_path)
        xml.guid user_thoughtlet_url(thoughtlet.to_path)
        xml.description thoughtlet.content
      end
    end
  end
end