module CssHelper
  def add_style_file(arg)
    (@style_files ||= []) << arg
  end
  
  def link_style_files
    (@style_files ||= []).map do |style|
      stylesheet_link_tag style
    end.join('\r\n')
  end
  
  def br_clear
    '<br style="clear: both;" />'
  end
end