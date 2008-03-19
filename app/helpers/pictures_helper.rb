module PicturesHelper
  def default_user_image
    "/images/default_user_image.jpg"
  end

  def default_user_image_thumb
    "/images/default_user_image_thumb.jpg"
  end

  def user_image_thumb_path( user_image = nil )
    return default_user_image_thumb unless user_image
    user_image.public_filename(:thumb)
  end

  def user_image_path( user_image = nil )
    return default_user_image unless user_image
    user_image.public_filename
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
  
  def picture_for(record, html_opts={})
    picture, class_str, dom_id_str = picture_and_dom_id_for(record)
    if picture
      image_tag(picture.public_filename, picture_html_opts_for(record).merge(html_opts))
    else
      default_picture_for(record.class.class_name, html_opts)
    end
  rescue
    ''
  end
  
  def default_picture_for(klass_name, html_opts={})
    file_path = [ klass_name.underscore, 'default.gif' ].join('/')
    image_tag(file_path, { :class => picture_class_str_for(klass_name) }.merge(html_opts))
  end
  
  def picture_html_opts_for(record)
    if arr = picture_and_dom_id_for(record)
      { :class => arr[0], :id => arr[1] }
    else
      {}
    end
  end
  
  def picture_and_dom_id_for(record)
    picture = record.primary_picture
    [ picture, picture_class_str_for(record),
      picture_id_str_for(record, picture) ] if picture
  end
  
  def picture_class_str_for(record_or_klass_name)
    if record_or_klass_name.is_a?(String)
      record_or_klass_name.underscore + 'Pic'
    else
      record.class.class_name.underscore + 'Pic'
    end
  end
  
  def picture_id_str_for(record, picture=nil)
    record.class.class_name.underscore + 'Pic-' +
    "#{record.id}-#{(picture || record.primary_picture).id}"
  end
end
