module WidgetsHelper
  
  def valid_widget_keys
    [ :events, :entries, :friends, :articles, :comments, :pictures, :galleries ]
  end
  
  def wcommon_locals(hash={})
    { :user => hash.delete(:user) || User.find_by_id(hash.delete(:user_id)) ||
      @user || User.find_by_id(@layoutable[:user_id]), :position => @wcount }.merge(hash)
  end
  
  def layout_base_path(layout_name=nil)
    [ '/layouts', layout_name || @layoutable.layout ].compact.join('/')
  end
  
  def wid_partial_for(widget, opts={})
    check_layoutable
    [ layout_base_path,
      partial_path(widget.widgetable) + (opts[:kind] ? "_#{opts[:kind]}" : '') ].join('/')
  end
  
  def wid_layout(layout=nil)
    return nil if layout == :none
    layout ||= 'widget'
    [ layout_base_path, layout.to_s ].join('/')
  end
  
  # wrender :rss, :url => 'http://blahblah.com'
  # wrender :entries
  # wrender :entries, :kind => :latest
  # wrender :entries, :kind => :latest, :limit => 5
  def widget_render(*args)
    check_layoutable
    @wcount ||= -1
    @wcount += 1    
    opts = args.extract_options!
    case var = args.first
    when Symbol # :events, :entries, :friends, :comments
      opts[:model] = 'rss_item' if var == :rss_item
      opts[:model] = 'user' if [ :events, :entries, :friends, :comments ].include?(var)
      wrender_special var, opts
    when Widget
      render :partial => wid_partial_for(var, :kind => opts[:kind]),
             :locals => wcommon_locals.merge(:widget => var,
                                            :"#{var.widgetable_type.underscore}" => var.widgetable).merge(opts),
             :layout => wid_layout(opts[:layout])
    when nil # wrender
      orig_count = @wcount
      @wcount -= 1
      wrender(@widgets[orig_count], opts) unless @widgets[orig_count].nil?
    end
  end
  alias_method :wrender, :widget_render
    
  def widget_render_special(method, opts={})
    check_layoutable
    layout = opts.delete(:layout)
    prefix, *rest = method.to_s.split('_')
    model = opts.delete(:model) || rest.join('_')
    model = method.to_s if model.blank?
    path = [ layout_base_path, model.pluralize, method.to_s ].join('/')
    render :partial => path, :locals => wcommon_locals.merge(opts),
                             :layout => wid_layout(layout)
  end
  alias_method :wrender_special, :widget_render_special
  
  def check_layoutable
    raise LayoutError, "@layoutable instance variable not set." unless @layoutable; true
  end
end
