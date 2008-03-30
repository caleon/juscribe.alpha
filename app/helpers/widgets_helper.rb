module WidgetsHelper
  class PageWidget
    def initialize(*args)
      @opts = args.extract_options!
      @arg = args.shift
    end
    attr_accessor :opts, :arg
    
    def for_widget?; arg.is_a?(Widget); end
    def for_special?; arg.is_a?(Symbol); end
    def for_path?; arg.is_a?(String); end
    
    def display; wrender(@opts, @opts);  end
  end
  
  def widget_args=(array); array.map{|arr| PageWidget.new(*arr) }; end
  alias_method :wargs=, :widget_args=
  
  def check_layoutable
    raise LayoutError, "@layoutable instance variable not set." unless @layoutable; true
  end
  
  def layout_base_path(layout_name=nil)
    if @layoutable.layouting
      [ '/layouts', layout_name || @layoutable.layouting.name ].compact.join('/')
    else
      ''
    end
  end
  
  def custom_partial(path) # Needed for now for stuff like blogs-index
    check_layoutable
    [ layout_base_path, path ].join('/')
  end
  
  def widget_layout(layout=nil)
    return nil if layout == :none
    return layout unless layout.nil? || layout.is_a?(Symbol)
    layout ||= :widget
    [ layout_base_path, 'widgets', layout.to_s ].join('/')
  # pointless:
  #rescue
  #  [ layout_base_path, 'shared', layout.to_s ].join('/')
  end
  alias_method :wayout, :widget_layout
  
  def path_from_sym(sym, kind=nil)
    instance_name = main_object.class.class_name.underscore
    kind = "_#{kind}" if kind
    if main_object.respond_to?(sym)
      "#{instance_name.pluralize}/#{sym}#{kind}"
    elsif (sym.to_s.singularize.classify.constantize rescue false)
      "#{sym.to_s.pluralize}/#{sym.to_s}#{kind}"
    else
      method, dir = sym.to_s.match(/^[^_]+_(.*)$/).to_a
      dir = dir ? dir.pluralize : 'main'
      [ dir.pluralize, "#{method}#{kind}" ].join('/')
    end
  end
  
  def widget_render(*args)
    check_layoutable
    @wcount ||= 0; @widgets ||= []
    opts = args.extract_options!
    kind = opts[:kind] ? "_#{opts[:kind]}" : ""
    arg = args.shift
    @wcount += 1
    
    with_options :layout => wayout(opts.delete(:layout)) do |wid|
      case arg
      when Widget
        return wid.wrender_unauthorized unless arg.widgetable.accessible_by?(viewer)
        instance_name = arg.widgetable_type.underscore
        wid.render :partial => "#{instance_name.pluralize}/#{instance_name}#{kind}",
                   :object => arg.widgetable, :locals => { :widget => arg }.merge(opts)
      when Symbol
        wid.wrender_symbol(arg, opts)
      when String
        wid.render :partial => arg, :locals => opts
      when nil
        return wid.wrender_vacant unless widget = @widgets[@wcount - 1]
        return wid.wrender_unauthorized unless widget.widgetable.accessible_by?(viewer)
        @wcount -= 1 and return wid.wrender(widget, opts)
      end  
    end
  end
  alias_method :wrender, :widget_render
  
  def wrender_symbol(sym, opts={})
    return wrender_unauthorized(opts) unless (main_object.new_record? || main_object.accessible_by?(viewer))
    instance_name = main_object.class.class_name.underscore
    obj = main_object.respond_to?(sym) ? main_object.send(sym) : nil
    wrender_vacant unless obj
    render :partial => path_from_sym(sym, opts[:kind]),
           :object => params[:object] || obj,
           :layout => opts[:layout],
           :locals => { :"#{instance_name}" => main_object }
  end
  
  def wrender_vacant(opts={})
    render :partial => "widgets/vacant", :layout => opts[:layout], :locals => opts
  end
  
  def wrender_unauthorized(opts={})
    render :partial => "widgets/unauthorized", :layout => opts[:layout], :locals => opts
  end
  
  def wrender_default_ad(opts={})
    render :partial => path_from_sym(:google_ad), :layout => opts[:layout], :Locals => opts
  end
end
