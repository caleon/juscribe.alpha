xml.instruct! :xml, :version => "1.0"
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title APP[:name] + ': ' + @page_title
    xml.link user_events_url(@user)
    xml.description "Upcoming events for #{@user.display_name}"
    xml.language "en-gb"

    for event in @events
      xml.item do
        xml.pubDate event.created_at.rfc822
        xml.title event.name
        xml.link user_event_url(event.to_path)
        xml.guid user_event_url(event.to_path)
        xml.description event.content
      end
    end
  end
end
