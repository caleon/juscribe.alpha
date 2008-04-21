require 'rss/2.0'
require 'open-uri'

module FeedsHelper
  class RssItem
    def initialize(feed_attrs, item_attrs)
      @feed_link = feed_attrs[:link]
      @feed_title = feed_attrs[:title]
      @item_link = item_attrs[:link]
      @item_title = item_attrs[:title]
      @item_author = item_attrs[:author]
      @item_content = item_attrs[:content]
      @item_published_date = item_attrs[:published_date]
      @item_guid = item_attrs[:guid]
    end
    
    def self.class_name; "RssItem"; end
    
    attr_reader :feed_link, :feed_title, :item_link, :item_title,
                :item_author, :item_content, :item_published_date, :item_guid
  end
  
  # Why is this camelcased?
  def parseFeed(feed_url)
    rss_item = nil
    open(feed_url) do |http|
      response = http.read
      result = RSS::Parser.parse(response, false)
      latest = result.items.first
      rss_item = RssItem.new( { :link => result.channel.link, :title => result.channel.title },
                              { :link => latest.link, :title => latest.title, :author => latest.author,
                                :content => latest.description, :published_date => latest.pubDate, :guid => latest.guid } )
    end
    return rss_item
  end
  
  def rss_link_for(kind, path, opts={})
    str = "RSS Feed for #{kind}"
    link_to image_tag('shim.gif', :class => 'rss_image', :width => 27, :height => 15, :alt => 'RSS Icon'), path, :class => 'rss_link', :title => str
  end
  
  def primary_picture_node(feed)
    doc = Hpricot(feed.item_content)
    (doc/"img").first
  end
    
  def format_feed(feed)
    doc = Hpricot(truncate_html(simple_format(sanitize(feed.item_content, :tags => %w( a img em i strong b )), :class => 'articleContent'), 500))
    first_p = (doc/".articleContent").first
    (doc/"img").remove
    first_p.inner_html = primary_picture_node(feed).to_html + first_p.inner_html
    (doc/"a:empty").remove # In case the removed images were wrapped in a link
    (doc/"a").each {|link| link.set_attribute('class', 'external') and link.set_attribute('target', '_new') if link.attributes['href'].match(/:\/\//) }
    doc.to_html
  end
end