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
  
  def picture_for(record, opts={})
    includes = opts.delete(:include) || []
    includes.push(:depictable) unless includes.last == :depictable
    picture = record.primary_picture rescue record.pictures.first
    if picture
      image_tag(picture.public_filename,
                :class => dom_class(picture, :include => includes),
                :id => dom_id(picture, :include => includes) )
    else
      default_picture_for(record.class.class_name,
                          :class => dom_class(Picture, :include => includes) )
    end
  rescue
    ''
  end
  
  def default_picture_for(klass_name, html_opts={})
    file_path = [ klass_name.underscore, 'default.gif' ].join('/')
    image_tag(file_path, html_opts)
  end
end
