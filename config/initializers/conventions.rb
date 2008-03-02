ActionController::RecordIdentifier.class_eval do
  def dom_class(record_or_class, *args)
    opts = args.last.is_a?(Hash) ? args.pop : {}
    item = opts.delete(:item)
    [ singular_class_name(record_or_class), item ].compact * '-'
  end
  
  def dom_id(record, *args) 
    prefix = args.first.is_a?(Hash) ? nil : args.shift
    opts = args.first.is_a?(Hash) ? args.shift : {}
    item = opts.delete(:item)
    [ prefix, singular_class_name(record), record.id, item ].compact * '-'
  end
end

ActionView::Helpers::RecordTagHelper.class_eval do
  def content_tag_for(tag_name, record, *args, &block)
    prefix  = args.first.is_a?(Hash) ? nil : args.shift
    options = args.first.is_a?(Hash) ? args.shift : {}
    item = options.delete(:item)
    concat content_tag(tag_name, capture(&block), 
      options.merge({ :class => "#{dom_class(record, :item => item)} #{options[:class]}".strip, :id => dom_id(record, prefix, :item => item) })), 
      block.binding
  end
end