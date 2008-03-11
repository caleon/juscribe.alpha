module LinkTagHelper
  class LinkAbstract
    def initialize(*args)
      @options = args.extract_options!
      @content = args.shift
    end
    
    def content; @content; end
    def options; @options; end
  end
  
  def link_made_tag; tagarize_link links[:made]; end
  def set_link_made!(user, opts={})
    set_link!(:made, {:rev => 'made', :title => 'Message Author', :href => message_user_path(user)}, opts)
  end
  
  def link_author_tag; tagarize_link links[:author]; end
  def set_link_author!(user, opts={})
    set_link!(:author, {:rel => 'author', :title => 'About the Author', :href => about_user_path(user)}, opts)
  end
  
  def link_top_tag; tagarize_link links[:top]; end
  def set_link_top!(path, opts={})
    set_link!(:top, {:rel => 'top', :title => 'Top of Site', :href => path}, opts)
  end
  
  def link_contents_tag; tagarize_link links[:contents]; end
  def set_link_contents!(path, opts={})
    set_link!(:contents, {:rel => 'contents', :title => 'Site Contents', :href => content_path}, opts)
  end
  
  def link_search_tag; tagarize_link links[:search]; end
  def set_link_search!(path, opts={})
    set_link!(:search, {:rel => 'search', :title => 'Search Site', :href => searches_path}, opts)
  end
  
  def link_help_tag; tagarize_link links[:help]; end
  def set_link_help!(opts={})
    set_link!(:help, {:rel => 'help', :title => 'Site Help', :href => help_path}, opts)
  end
  
  def link_copyright_tag; tagarize_link links[:copyright]; end
  def set_link_copyright!(opts={})
    set_link!(:copyright, {:rel => 'copyright', :title => 'Site Copyright', :href => copyright_path}, opts)
  end
  
  def link_up_tag; tagarize_link links[:up]; end
  def set_link_up!(opts={})
    set_link!(:up, {:rel => 'up', :title => 'Up Hierarchy', :href => '../'}, opts)
  end
  
  def link_tags; tagarize_link(*links.values); end
  

  def links
    @link_hash ||= {}
  end
  
  def set_link!(kind, defaults, opts={})
    links[kind] = LinkAbstract.new(defaults.merge(opts).merge(:rel => kind.to_s))
  end
  
  def tagarize_link(*link_abstracts)
    link_abstracts.compact.map {|lnk| content_tag(:link, lnk.content, lnk.options) }.join("\r\n")
  end
end