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
  
  def get_canvas_class
    "#{controller.controller_name}-#{controller.action_name}"
  end
  
  def warning_field
    content_tag(:div, flash[:warning], :id => 'flashWarning', :class => 'flashBox') if flash[:warning]
  end
  
  def notice_field
    content_tag(:div, flash[:notice], :id => 'flashNotice', :class => 'flashBox') if flash[:notice]
  end
  
  def navi_el(text, path, opts={})
    opts[:style] = [ opts[:style], "z-index: -1;" ].compact.join(' ')
    conditions = opts[:conditions].nil? ? true : opts.delete(:conditions)
    right, first = opts.delete(:right), opts.delete(:first)
    content_tag(:li, link_to(text, path, opts), :class => "navigationEl#{' right' if right}#{' first' if first}", :style => "z-index: -1;") if conditions
  end

  def bread_el(text, path, opts={})
    z_index = 10 - (@bread_count ||= 0)
    @bread_count += 1
    opts[:style] = [ opts[:style], "z-index: #{z_index};" ].compact.join(' ')
    current, first = opts.delete(:current), opts.delete(:first)
    content_tag(:li, link_to(text, path, opts), :class => "navigationEl breadcrumbEl#{' current' if current}#{' first' if first}", :style => "z-index: #{z_index};")
  end
								
  def navi_skin_info
    navi_el "Layout: <span class=\"layout_name\">#{@layoutable.layout}</span> - Skin: <span class=\"skin_name\">#{@layoutable.skin}</span>",
            (@user && @user.editable_by?(viewer) ? edit_user_path(@user) : '#'),
            :right => true if @layoutable
  end
  
  def navi_customize(path)
    navi_el 'Customize', path, :right => true if @layoutable && @layoutable.editable_by?(viewer)
  end
  
  def byline_for(record)
    render :partial => "#{record.class.class_name.pluralize.underscore}/byline",
                       :locals => { :"#{record.class.class_name.underscore}" => record }
  end
  
end
