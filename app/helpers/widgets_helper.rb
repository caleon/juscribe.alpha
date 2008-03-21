module WidgetsHelper
  
  def layout_base_path(layout_name=nil)
    [ '/layouts', layout_name || @layoutable.layout ].compact.join('/')
  end
  
  def custom_partial(path) # Is this used? I think I'll need it.
    check_layoutable
    [ layout_base_path, path ].join('/')
  end
  
  def widget_layout(layout=nil)
    return nil if layout == :none
    layout ||= 'widget'
    [ layout_base_path, layout.to_s ].join('/')
  end
  
  def increment_skippables
    [ :motd_message, :rss_item, :google_ads ]
  end
  
  def widget_render(*args)
    check_layoutable
    @wcount ||= 0
    @widgets ||= []

    opts = args.extract_options!
    kind = opts[:kind] ? "_#{opts[:kind]}" : ""
    sym_or_wid = args.shift

    case sym_or_wid
    when Widget
      @wcount += 1
      instance_name = sym_or_wid.widgetable_type.underscore
      render :partial => "#{instance_name.pluralize}/#{instance_name}#{kind}",
             :object => sym_or_wid.widgetable,
             :locals => { :widget => sym_or_wid }.merge(opts),
             :layout => widget_layout(opts[:layout])
    when Symbol
      @wcount += 1 unless increment_skippables.include?(sym_or_wid)
      instance_name = @layoutable.class.class_name.underscore
      render :partial => path_from_sym(sym_or_wid, opts[:kind]),
             :object => params[:object] ||
                        (@layoutable.send(sym_or_wid) if @layoutable.respond_to?(sym_or_wid)),
             :locals => { :"#{instance_name}" => @layoutable  }.merge(opts),
             :layout => widget_layout(opts[:layout])
    when nil
      wrender(@widgets[@wcount], opts) unless @widgets[@wcount].nil?
    else
      raise "Invalid argument to #wrender. Expected Widget or Symbol or nil" if RAILS_ENV == 'development'
    end  
  end
  alias_method :wrender, :widget_render
  
  def path_from_sym(sym, kind=nil)
    instance_name = @layoutable.class.class_name.underscore
    kind = "_#{kind}" if kind
    if @layoutable.respond_to?(sym)
      "#{instance_name.pluralize}/#{sym}#{kind}"
    elsif (sym.to_s.singularize.classify.constantize rescue false)
      "#{sym.to_s.pluralize}/#{sym.to_s}#{kind}"
    else
      method, dir = sym.to_s.match(/^[^_]+_(.*)$/).to_a
      dir = dir ? dir.pluralize : 'main'
      [ dir.pluralize, "#{method}#{kind}" ].join('/')
    end
  end
  
  def check_layoutable
    raise LayoutError, "@layoutable instance variable not set." unless @layoutable; true
  end
end
