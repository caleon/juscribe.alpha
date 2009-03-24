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
  
  def draft_path_for(draft, opts={})
    instance_val %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{draft.path_name_prefix}_#{opts[:url] ? 'url' : 'path'}(draft.to_path.merge(opts[:params] || {})) }
  end
  
  def draft_url_for(draft, opts={})
    draft_path_for(draft, opts.merge(:url => true))
  end
  
  def draft_path_from_blog(blog, opts={})
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{blog.path_name_prefix}_draft_path(blog.to_path(true).merge(opts[:params] || {})) }
  end
  
  def drafts_path_from_blog(blog, opts={})
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{blog.path_name_prefix}_drafts_path(blog.to_path(true).merge(opts[:params] || {})) }
  end
  
  def latest_articles_url_for(object, opts={})
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{object.path_name_prefix}_latest_articles_url(object.to_path(true)) }
  end
  
  # FIXME: If the article record no longer exists, this will error out.
  def articles_history(limit=5)
    Article.find(session[:articles_history] ||= []).compact.sort_by {|art| session[:articles_history].index(art.id) }
  end
  
  
  ################################
  ##     ARTICLE FORMATTING     ##
  ################################
  
  # TODO: A blog can remove/customize this intro on premium accounts
  def article_intro
    content_tag :strong, "(#{APP[:name].upcase}) &mdash;", :class => 'articleIntro'
  end
  
  # Here is where to add more types of components per article
  def article_components_for(article)
    article.pictures[1..-1] || []
  end
  
  def render_article_component(article, text_or_model)
    case text_or_model
    when Picture
      if feature = text_or_model.thumbnails.find_by_thumbnail('feature')
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
  
  # format_article will create a proper DOM structure so that unwrapped text nodes are wrapped in P
  # tags and allowed block-level elements exist outside of the P tags. Furthermore, each direct
  # descendant of the wrapping .article element (created outside #format_article) will have an
  # 'articleContent' class name for consistent styling.
  #
  # Currently the method will also mix in article images throughout the post within set intervals,
  # but TODO: the interval should factor in the overall length of the article as well, in order to
  # evenly space out images as much as possible instead of having a bunch of pictures at the top
  # of a long article and only text down below.
  #
  # The mixing in functionality is supposed to allow other elements besides pictures to appear.
  # This will allow modules like "You may also like" to be mixed into an article.
  #
  # Lastly, an empty SPAN element is added to the end of the .articleContent element to be populated
  # via Javascript with comments corresponding to that paragraph.
  #
  # NOTE: The following helper methods need to be in a certain order to avoid conflicting with each other.
  # TODO: Should also Hpricot the input before we save to database on Article#save.
  def format_article(article, opts={})
    opts[:article] ||= article || @article
    text = escape_code_html(article.content)
    text = article_intro + text unless opts[:without_intro]
    formatted = Hpricot(p_wrap(text)) # This already escapes invalid HTML tags...
    clean_code_breaks(formatted)       # But this needs to escape all HTML tags within CODE/PRE
    clarify_external_links(formatted)
    # Remove unwanted html attributes like onclick
    text = sanitize(formatted.to_html, :tags => allowed_tags(opts[:truncate]), :attributes => allowed_attributes)
    hpricot = Hpricot(text)
    prep_with_mixins(hpricot, opts)
    opts[:truncate] ? truncate_html(hpricot.to_s, opts[:truncate]) : hpricot.to_s
  end
  
  # Create desired DOM hierarchy
  def p_wrap(text, opts={})
    # Actually if opts[:truncate], we might wanna remove the bad tags entirely instead of escaping...
    my_allowed_tags = opts[:tags].is_a?(Array) ? opts[:tags] : (allowed_tags - %w(p))
    # Basically these are types that cannot exist within a P tag. P is not allowed, however.
    # TODO: Style h1-h3 so that they are at greatest the size of an h3.
    block_levels = "pre|blockquote|h1|h2|h3|h4|h5|h6|ol|ul"
    res = text.to_s.
          gsub(/(<\/?(\w+)[^>]*>)/) {|t| my_allowed_tags.include?($2) ? $1 : h($1)}.
          gsub(/\r\n?/, "\n").
          gsub(/\n\n+/, "</p>\n\n<p>")
    res = "<p>" + res + "</p>"

    res.gsub(/(<(?:#{block_levels})>)/, "</p>\n\\1").gsub(/(<\/(?:#{block_levels})>)/, "\\1\n<p>").
        gsub(/\s*<p><\/p>\s*/, "\n"). # Fuck. This performs within a PRE tag...
        gsub(/([^\n|>]\n)(?!\n)/, "\\1<br />\n").strip
  end
  
  # Escape html tags within PRE or CODE  
  def escape_code_html(text)
    text.gsub(/<code[^>]*>(.*?)<\/code>/m) do |t|
      "<code>" + h($1) + "</code>"
    end.gsub(/<pre[^>]*>(.*?)<\/pre>/m) do |t|
      "<pre>" + h($1) + "</pre>"
    end
  end
  
  def clean_code_breaks(hpricot)
    (hpricot/"pre, code").each do |code_el|
      code_el.inner_html = code_el.inner_html.gsub(/\n*<br \/>\n*/, "\n").gsub(/\n*<\/?p>\n*/, "\n\n")
    end    
  end
  
  # Make external links styled differently and open in new window
  def clarify_external_links(hpricot)
    (hpricot/"a").each {|link| link.set_attribute('class', 'external') and link.set_attribute('target', '_new') unless link.attributes['href'].match(/:\/\/(\w+\.)?juscribe\.com(\/[-_\/\?\w]*)?$/)} # Test forging with juscribe.com.hacker.com
  end
  
  # Set class and unique IDs for each block level element for this articleContent
  def prep_with_mixins(hpricot, opts={})
    raise ArgumentError unless article = opts[:article] || @article
    component_count, aggregate_length = 0, 0
    # each_child_with_index are first-level elements within .article.
    hpricot.each_child_with_index do |child, i|
      if child.elem?
        # IMPORTANT: the following digest code cannot change, else it will mess up associations
        # It should also be set before modifications to the entire element, like class, id, inner_html...
        paragraph_id = paragraph_id_for(child, opts) unless opts[:truncate] || opts[:without_comps]
        child.set_attribute('class', opts[:class] || 'articleContent')
        unless opts[:truncate] || opts[:without_comps]
          child.set_attribute('id', paragraph_id)
          # The following WAS necessary to make highlighting of paragraph render above previous paragraphs
          # but we are not highlighting paragraphs anymore.
          # child.set_attribute('style', "z-index: #{50 - i/2};")
          if aggregate_length > 1400 && child.name == 'p' && comp = article_components_for(article)[component_count] 
            child.inner_html = render_article_component(article, comp) + child.inner_html
            aggregate_length = child.inner_text.mb_chars.length
            component_count += 1
          else
            aggregate_length += child.inner_text.mb_chars.length
          end
          create_comment_mixin(child, paragraph_id) unless %w(pre).include?(child.name) || child.inner_text.mb_chars.length < 150
        end
      end
    end
  end
  
  def paragraph_id_for(hp_el, opts={})
    raise ArgumentError unless article = opts[:article] || @article
    "#{opts[:prefix] ? "#{opts[:prefix]}_" : ''}" +
    "a-#{article.id}-" + 
    "p-#{Digest::SHA1.hexdigest(hp_el.to_s)[0..6]}"
  end

  def create_comment_mixin(hp_el, paragraph_id)
    hp_el.inner_html += content_tag(:span, "#{@article.comments_for(paragraph_id).size}", :class => paragraph_id + "-comment article-mixedComment mixedComment")
  end
end
