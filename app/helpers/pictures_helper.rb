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
  
  def caption_for(picture, opts={})
    return '' if !(picture && !picture.caption.blank?)
    content_tag(:span, picture.caption, opts.merge(:class => 'caption')) if picture && !picture.caption.blank?
  end
  
  def picture_for(record, opts={})
    includes = opts.delete(:include) || []
    includes.push(record) if includes.last != record
    with = opts.delete(:with) || {}
    
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
    link_to_if opts[:link],
      (if picture
        dom_class_str = [ dom_class(picture, :include => includes), with[:class] ].compact.join(' ')
        dom_id_str = dom_id(picture, :include => includes)
        image_tag(picture.public_filename,
                  { :class => dom_class_str, :id => dom_id_str, :alt => picture.caption, :width => picture.width, :height => picture.height } )
      else
        default_picture_for(record.class.class_name,
                            :class => dom_class(Picture, :include => includes) )
      end + (opts[:with_text] ? "<br />#{opts[:text] || opts[:title] || record.display_name}" : '')),
      (opts[:link].is_a?(String) ? opts[:link] : record), :title => opts[:title] || record.display_name, :class => "#{record.class.class_name.underscore}Link"
  rescue
    ''
  end
  
  def default_picture_for(klass_name, html_opts={})
    file_path = [ klass_name.underscore, 'default.gif' ].join('/')
    image_tag(file_path, { :alt => "Default #{klass_name.humanize} picture" }.merge(html_opts))
  end
end
