# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def get_viewer; @viewer; end
  def logged_in?; !get_viewer.nil?; end
  def this_is_viewer?; @user && !@user.new_record? && logged_in? && @user == get_viewer; end
  
  def main_object
    instance_variable_get("#{controller.class.shared_setup_options[:instance_var]}") || instance_variable_get("#{controller.class.shared_setup_options[:collection_owner_var]}")
  rescue
    nil
  end
  
  def subnav_for(record)
    locals = { :"#{record.class.class_name.underscore}" => record }
    case record
    when Article 
      locals[:blog] = record.blog
      locals[:author] = record.author
    when Blog
      locals[:bloggable] = record.bloggable
    else
      locals[:user] = record.user
    end
    render :partial => "#{record.class.table_name}/subnavigation", :locals => locals
  end
    
  ### Refer to config/initializers/action_controller_tweaks.rb
  def responding_types; @responding_types ||= [:html]; end
  def action_accepts?(type); responding_types.include?(type); end
  
  def body_tag_for(*args, &block)
    opts = args.extract_options!
    record = args.shift
    concat content_tag(:body, capture(&block),
                       (opts.merge(record ? { :id => "#{record.class.class_name}Page" } : {:id => 'Page'})))
  end

  def get_canvas_class
    "#{controller.controller_name}-#{controller.action_name} #{controller.action_name}"
  end
  
  def warning_field
    content_tag(:div, 
      content_tag(:div, flash[:warning], :id => 'flashWarning-inner'), :id => 'flashWarning', :class => 'flashBox', :style => "#{'display: none;' unless flash[:warning]}")
  end
  
  def notice_field
    content_tag(:div, 
      content_tag(:div, flash[:notice], :id => 'flashNotice-inner'), :id => 'flashNotice', :class => 'flashBox', :style => "#{'display: none;' unless flash[:notice]}")
  end
  
  def navi_el(text, path, opts={})
    @navi_count ||= 0
    css_class = [ 'navigationEl' ]
    conditions = opts[:conditions].nil? ? true : opts.delete(:conditions)
    css_class << 'current' if opts.delete(:current)
    css_class << 'right' if opts.delete(:right)
    css_class << 'first' if @navi_count == 0
    @navi_count += 1
    opts[:title] ||= strip_tags(text)
    content_tag(:li, link_to(text, path, opts), :class => css_class.join(' ')) if conditions
  end
  
  def subnavi_el(text, path, opts={})
    if (@subnav_count ||= 0) == 0
      @subnav_count = 1 # dont need to increment for now.
      @navi_count = 0
    end
    navi_el(text, path, opts)
  end
  
  def clip_subnavi_el(record)
    return nil unless logged_in? && record && !record.new_record? && record.accessible_by?(get_viewer)
    #if clip = record.clip_for(get_viewer)
    #  subnavi_el image_tag('shim.gif', :class => 'shim') + "Unclip", clip_path_for(clip), :method => :delete, :class => 'un clipLink', :id => record.class.class_name.downcase + "-clipLink"
    #else
    unless record.clip_for?(get_viewer)
      subnavi_el image_tag('shim.gif', :class => 'shim'), clip_path_from_widgetable(record, :prefix => :new), :class => 'clipLink', :id => record.class.class_name.downcase + "-clipLink", :title => "Clip this #{record.class_name}"
    end
  end
  
  def bread_el(text, path, opts={})
    z_index = 10 - (@bread_count ||= 0)
    css_class = [ 'navigationEl', 'breadcrumbEl' ]
    @bread_count += 1
    opts[:style] = [ opts[:style], "z-index: #{z_index};" ].compact.join(' ')
    css_class << 'current' if opts.delete(:current)
    css_class << 'first' if opts.delete(:first)
    opts[:title] ||= strip_tags(text)
    content_tag(:li, link_to(text, path, opts), :class => css_class.join(' '), :style => "z-index: #{z_index};")
  end
								
  def navi_skin_info
    navi_el "Skin: #{main_object.layout_name rescue Layouting::DEFAULT_LAYOUT}",
            (@user && @user.editable_by?(get_viewer) ? edit_user_path(@user) : '#'),
            :right => true
  end
  
  def navi_customize(path)
    navi_el image_tag('shim.gif', :class => 'shim') + 'Customize', path, :class => 'nav-customize', :right => true, :current => controller.controller_name == 'widgets' if main_object && main_object.editable_by?(get_viewer)
  end
  
  def cancel_button
    button_to 'Cancel', controller.previous_view, :method => :get
  end
  
  def byline_for(record, locals={})
    render :partial => "#{record.class.class_name.pluralize.underscore}/byline",
                       :locals => { :"#{record.class.class_name.underscore}" => record }.merge(locals)
  end
  
  def debug_module
    render :partial => 'shared/debugger' if RAILS_ENV == 'development' || (get_viewer && get_viewer.admin? && SITE[:enable_debugger])
  end
  
  def preview_path_for(record)
    instance_eval %{ preview_#{record.path_name_prefix}_path(record.to_path) }
  end
  
  def browser(*args)
    # TODO: SETUP non-JS based alternative
    # Check size of args to determine width of each column in CSS by applying class names,
    # Render a partial for each pane, including special preview pane for last
    content_tag :ul,
      content_tag(:li, render(:partial => 'shared/browser_column', :locals => { :name => args.first.to_s.humanize,
                              :sym => args.first, :collection => instance_variable_get("@#{args.first}") }),
                       :class => 'browser-col') +
      content_tag(:li, render(:partial => 'shared/preview_pane', :locals => { :sym => args.last }), :class => 'browser-col'),
                      :id => 'browser'
      
  end
  
  def timepiece_for(timestamp)
    # TODO: factor in time zones
    hour = timestamp.hour
    image_tag 'shim.gif', :class => "timepiece at#{sprintf("%02d", hour)}"
  end
  
  def timestamp_for(timestamp)
    timestamp.inspect # Stubbed
  end
  
  def registration_closed?
    RAILS_ENV == 'production' && (SITE[:defcon] == 0 || SITE[:disable_registration])
  end
  
end
