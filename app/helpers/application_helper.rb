# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def viewer; @viewer; end
  def logged_in?; !viewer.nil?; end
  def this_is_viewer?; @user && !@user.new_record? && logged_in? && @user == viewer; end
    
  ### Refer to config/initializers/action_controller_tweaks.rb
  def responding_types; @responding_types ||= [:html]; end
  def action_accepts?(type); responding_types.include?(type); end
  
  def body_tag_for(*args, &block)
    opts = args.extract_options!
    record = args.shift
    concat content_tag(:body, capture(&block),
                       (opts.merge(record ? { :id => "#{record.class.class_name.downcase}Page" } : {:id => 'Page'}))),
           block.binding
  end
  
  def main_record
    @user || @group || @widget || @article || @event || @entry || @list || @item
  end
  
  def warning_field
    content_tag(:div, flash[:warning], :id => 'flashWarning', :class => 'flashBox') if flash[:warning]
  end
  
  def notice_field
    content_tag(:div, flash[:notice], :id => 'flashNotice', :class => 'flashBox') if flash[:notice]
  end
  
  def navi_el(text, path, opts={})
    conditions = opts[:conditions].nil? ? true : opts.delete(:conditions)
    content_tag(:li, link_to(text, path, opts), :class => 'navigationEl') if conditions
  end
  
end
