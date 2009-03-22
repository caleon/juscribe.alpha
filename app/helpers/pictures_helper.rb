module PicturesHelper
  def user_image_thumb_path( user_image = nil )
    return default_user_image_thumb unless user_image
    user_image.public_filename(:thumb)
  end
  
  def picture_path_for(picture, opts={})
    opts[:params] ||= {}
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{picture.path_name_prefix}_path(picture.to_path.merge(opts[:params])) }
  end
  
  def picture_path_from_depictable(depictable, opts={})
    opts[:params] ||= {}
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{depictable.path_name_prefix}_#{opts[:suffix] || 'picture'}_path(depictable.to_path(true).merge(opts[:params])) }
  end
  
  def pictures_path_from_depictable(depictable, opts={})
    picture_path_from_depictable(depictable, opts.merge(:suffix => 'pictures'))
  end
  
  def depictable_path_for(depictable, opts={})
    opts[:params] ||= {}
    instance_eval %{ #{opts[:prefix] ? "#{opts[:prefix]}_" : ''}#{depictable.path_name_prefix}_path(depictable.to_path.merge(opts[:params])) }
  end
  
  def zoomable_picture_with(picture, opts={})
    if picture
      original = picture.original? ? picture : picture.parent
      feature = picture.feature? ? picture : picture.thumbnails.find_by_thumbnail('feature')
      res = <<-EOB
        <a href="#{picture_path_for(original)}" rel="lightbox[article_#{opts[:article_id]}]" class="article_picture_link#{' right' if (opts[:with] ||= {}) && opts[:with][:class].to_s.match(/right/)}" title="#{h(picture.caption) if !picture.caption.blank?}">
          #{just_picture_tag(feature, :with => opts[:with])}
          #{caption_for(feature)}
          <span class="picture-symbol">&nbsp;</span>
          <span class="zoomer">+</span>
        </a>
      EOB
    end
  end
  
  def caption_for(picture, opts={})
    return '' if !(picture && !picture.caption.blank?)
    content_tag(:span, picture.caption, opts.merge(:class => 'caption')) if picture && !picture.caption.blank?
  end
  
  def picture_for(record, opts={})
    includes = opts.delete(:include) || []
    includes.push(record) if includes.last != record
    with = opts.delete(:with) || {}
    
    begin
      case opts[:type]
      when nil
        picture = record.primary_picture.thumbnails.find_by_thumbnail('feature')
      when :thumb
        picture = record.thumbs.first
      when :feature
        picture = record.primary_picture.thumbnails.find_by_thumbnail('feature')
      when :full
        picture = record.primary_picture
      end
    rescue
      picture = nil
    end
    link_to_if opts[:link],
      ( just_picture_tag(picture, :prefix => opts[:prefix], :include => includes, :with => with, :class => opts[:class]) + 
          ((opts[:with_text] || opts[:text]) ? "<br />#{opts[:text] || opts[:title] || record.display_name}" : '') ),
      (opts[:link].is_a?(String) ? opts[:link] : record || '#'), :title => opts[:title] || (record.display_name rescue opts[:class]), :class => "#{record.class.class_name.underscore rescue (opts[:class].underscore rescue nil)}Link"
  end
  
  def just_picture_tag(picture, opts={})
    includes = opts.delete(:include) || []
    includes.push(picture.depictable) if picture && includes.last != picture.depictable
    with = opts.delete(:with) || {}
    if picture
      dom_class_str = [ dom_class(picture, :include => includes), with[:class] ].compact.join(' ')
      dom_id_str = dom_id(picture, opts[:prefix], :include => includes)
      image_tag(picture.public_filename, { :class => dom_class_str, :id => dom_id_str, :alt => picture.caption } )
    else
      default_picture_for(opts[:class], :class => dom_class(Picture, :include => opts[:class] ? (includes << opts[:class].constantize) : includes) )
    end
  end
  
  def default_picture_for(klass_name=nil, html_opts={})
    klass_name = klass_name.blank? ? "" : klass_name
    # TODO: Should the default picture be uploaded to S3 as well? If so, can this be "seeded"?
    file_path = [ klass_name.underscore, 'default.png' ].join('/')
    image_tag(file_path, { :alt => "Default #{klass_name.humanize.downcase} picture" }.merge(html_opts))
  end
end
