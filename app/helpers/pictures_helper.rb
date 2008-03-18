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
  
  def picture_path_for(picture, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{picture.path_name_prefix}_path(picture.to_path) }
  end
  
  def depictable_path_for(depictable, acshun=nil)
    instance_eval %{ #{acshun ? "#{acshun}_" : ''}#{depictable.path_name_prefix}_path(depictable.to_path) }
  end
  
  def picture_for(record, html_opts={})
    picture, class_str, dom_id_str = picture_and_dom_id_for(record)
    image_tag(picture.public_filename, {:class => class_str, :id => dom_id_str}.merge(html_opts)) if picture
  rescue
    nil
  end
  
  def picture_and_dom_id_for(record)
    picture = record.primary_picture
    [ picture, "#{record.class.class_name.downcase}Pic",
      "#{record.class.class_name.downcase}Pic-#{record.id}-#{picture.id}" ] if picture
  end
end
