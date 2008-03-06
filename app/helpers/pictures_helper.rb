module PicturesHelper
  def picture_for(record, html_opts={})
    picture, class_str, dom_id_str = picture_and_dom_id_for(record)
    image_tag(file_path, {:class => class_str, :id => dom_id_str}.merge(html_opts)) if pic
  rescue
    nil
  end
  
  def picture_and_dom_id_for(record)
    picture = begin
      record.pictures.first
    rescue
      record.picture rescue nil
    end
    [ picture, "#{record.class.class_name.downcase}Pic",
      "#{record.class.class_name.downcase}Pic-#{record.id}-#{picture.id}" ] if picture
  end
end
