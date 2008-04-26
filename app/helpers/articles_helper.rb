module ArticlesHelper
  def article_path_for(article, opts={})
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{article.path_name_prefix}_#{opts[:url] ? 'url' : 'path'}(article.to_path.merge(opts[:params] || {})) }      
  end
  
  def article_url_for(article, opts={})
    article_path_for(article, opts.merge(:url => true))
  end
  
  def article_path_from_blog(blog, opts={})
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{blog.path_name_prefix}_article_path(blog.to_path(true).merge(opts[:params] || {})) }
  end
  
  def articles_path_from_blog(blog, opts={})
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{blog.path_name_prefix}_articles_path(blog.to_path(true).merge(opts[:params] || {})) }
  end
  
  def latest_articles_url_for(object, opts={})
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{object.path_name_prefix}_latest_articles_url(object.to_path(true)) }
  end
  
  def article_intro
    content_tag :strong, "(#{APP[:name].upcase}) &mdash;", :class => 'articleIntro'
  end
  
  def article_components_for(article)
    article.pictures[1..-1] || []
  end
  
  def render_article_component(article, text_or_model)
    case text_or_model
    when Picture
      if feature = text_or_model.thumbnails.find_by_thumbnail('feature')
#        image_tag(thumb.public_filename, :class => dom_class(thumb) + ' articleComponent ' + cycle('right', 'left'))
        zoomable_picture_with(feature, :article_id => article.id, :with => { :class => "articleComponent #{cycle('right', 'left')}" })
      end
    end
  end
  
  def allowed_tags(trunc=false)
    %w(strong em b i code pre tt samp kbd var sub 
      sup dfn cite big small address br span h1 h2 h3 h4 h5 h6 ul ol li abbr 
      acronym a img blockquote embed object param p) - (trunc ? %w( embed object param pre ) : [])
  end
  
  def allowed_attributes
    %w(href src width height alt target cite datetime title class name xml:lang abbr wmode type value)
  end
  
  def format_article(article, opts={})
    text = article.content
    text = article_intro + article.content unless opts[:without_intro]
    # Create desired DOM hierarchy and convert to Hpricot
    formatted = Hpricot(p_wrap(text))
    # Escape html tags within PRE or CODE
    (formatted/"pre, code").each do |code_el|
      code_el.inner_html = code_el.inner_html.gsub(/\n*<br \/>\n*/, "\n")
      code_el.inner_html = html_escape(code_el.inner_html)
    end
    # Make external links styled differently and open in new window
    (formatted/"a").each {|link| link.set_attribute('class', 'external') and link.set_attribute('target', '_new') if link.attributes['href'].match(/:\/\/\w+\.[^(juscribe\.com)](?:\/.*)?$/)} # Test forging with juscribe.com.hacker.com
    # Remove unwanted html attributes like onclick
    text = sanitize(formatted.to_html, :tags => allowed_tags(opts[:truncate]), :attributes => allowed_attributes)
    hpricot = Hpricot(text)
    # Set class and unique IDs for each block level element for this articleContent
    @component_count = 0
    @aggregate_length = 0
    hpricot.each_child do |child|
      if child.is_a?(Hpricot::Elem)
        child.set_attribute('class', 'articleContent')
        paragraph_id = "#{opts[:prefix] ? "#{opts[:prefix]}_" : ''}article-#{article.id}-paragraph-#{Digest::SHA1.hexdigest(child.inner_html)[0..6]}"
        child.set_attribute('id', paragraph_id)
        #if i.even? && !opts[:truncate] && (i >= 2 && comp = article_components_for(article)[(i-2)/2])
        #if i.even? && !opts[:truncate] && i > 4 && comp = article_components_for(article)[(i-4)/2]
        if @aggregate_length > 800 && comp = article_components_for(article)[@component_count] 
          child.inner_html = render_article_component(article, comp) + child.inner_html
          @aggregate_length = child.inner_text.chars.length
          @component_count += 1
        else
          @aggregate_length += child.inner_text.chars.length
        end
      end
    end
    text = opts[:truncate] ? truncate_html(hpricot.to_s, opts[:truncate]) : hpricot.to_s
    # Return finished
    text.to_s
  end
  
  # TODO: Need to Hpricot the input before we save to database on Article#save
  def p_wrap(text, opts={})
    # Actually if opts[:truncate], we might wanna remove the bad tags entirely instead of escaping...
    my_allowed_tags = opts[:tags].is_a?(Array) ? opts[:tags] : (allowed_tags - %w(p))
    # Basically these are types that cannot exist within a P tag. P is not allowed, however.
    block_levels = "pre|blockquote|h1|h2|h3|h4|h5|h6|ol|ul"
    res = text.to_s.
          gsub(/(<\/?(\w+)[^>]*>)/) {|t| my_allowed_tags.include?($2) ? $1 : h($1)}.
          gsub(/\r\n?/, "\n").
          gsub(/\n\n+/, "</p>\n\n<p>")
    res = "<p>" + res + "</p>"

    res.gsub(/(<(?:#{block_levels})>)/, "</p>\n\\1").gsub(/(<\/(?:#{block_levels})>)/, "\\1\n<p>").
        gsub(/\s*<p><\/p>\s*/, "\n").
        gsub(/([^\n|>]\n)(?!\n)/, "\\1<br />\n").strip
  end

  
  # FIXME: if the article record no longer exists, this will error out
  def articles_history(limit=5)
    Article.find(session[:articles_history] ||= []).compact.sort_by {|art| session[:articles_history].index(art.id) }
  end
end
