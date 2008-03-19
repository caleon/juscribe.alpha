module ActionController::RecordIdentifier  
  # IDEALLY: dom_class(comment, :include => [:group, :user, :event]) in descending order of hierarchy
  #  result => "comment event-comment user-event-comment group-user-event-comment"
  def dom_class(record_or_class, *args)
    opts = args.extract_options!
    prefix = args.shift
    res = []
    if prefix
      res << [ prefix, singular_class_name(record_or_class) ].compact * '-'
    else
      arr = opts[:include] || []
      arr = arr.map(&:to_s)
      arr.push(singular_class_name(record_or_class))
      0.upto(arr.size - 1) do |i|
        res << arr[i..(arr.size-1)].compact * '-'
      end
    end
    res.join(' ')
  end
  
  def dom_id_with_associations(record, *args) 
    opts = args.extract_options!
    prefix = args.shift
    sub_dom_id = nil
    if !opts[:include].blank?
      subarr = opts[:include].is_a?(Array) ? opts[:include] : [opts[:include]]
      sub_dom_id = dom_id(record.send(subarr.pop), :include => subarr)
    end
    [ prefix, sub_dom_id, singular_class_name(record), record.id ].compact * '-'
  end
  alias_method_chain :dom_id, :associations
end

module ActionView::Helpers::RecordTagHelper
  def content_tag_for_with_associations(tag_name, record, *args, &block)
    prefix  = args.first.is_a?(Hash) ? nil : args.shift
    options = args.first.is_a?(Hash) ? args.shift : {}
    child_hash = options.delete(:child)
    concat content_tag(tag_name, capture(&block), 
      options.merge({ :class => "#{dom_class(record, :child => child_hash)} #{options[:class]}".strip, :id => dom_id(record, prefix, :child => child_hash) })), 
      block.binding
  end
  alias_method_chain :content_tag_for, :associations
end