module ActionController::RecordIdentifier  
  # IDEALLY: dom_class(comment, :include => [:group, :user, :event]) in descending order of hierarchy
  #  result => "comment event-comment user-event-comment group-user-event-comment"
  def dom_class_with_associations(record_or_class, *args)
    opts = args.extract_options!
    prefix = args.shift
    opts[:include] = [opts[:include]] unless (opts[:include].is_a?(Array) || opts[:include].nil?)
    res = []
    if !opts[:include].blank?
      0.upto(opts[:include].size) do |i|
        res << dom_class_helper(record_or_class, prefix, :include => opts[:include][i..(opts[:include].size-1)])
      end
    else
      res << dom_class_helper(record_or_class, prefix)
    end
    res.join(' ')
  end
  alias_method_chain :dom_class, :associations
  # => dom_class_helper(com, :include => [ :user, :event ])
  # => which returns: "user-event-comment"
  def dom_class_helper(record_or_class, *args)
    opts = args.extract_options!
    prefix = args.shift
    opts[:include] = [opts[:include]] unless (opts[:include].is_a?(Array) || opts[:include].nil?)

    res = []
    if !opts[:include].blank?
      next_sym = opts[:include].pop
      if next_sym.respond_to?(:display_name)
        res << dom_class_helper(next_sym, prefix, :include => opts[:include])
      elsif record_or_class.is_a?(Class)
        res << dom_class_helper(next_sym.to_s.classify.constantize, prefix, :include => opts[:include])
      else
        res << dom_class_helper(record_or_class.send(next_sym), prefix, :include => opts[:include])
      end
    end
    res << singular_class_name(record_or_class)
    res.compact.join('-')
  rescue NameError
    nil
  end
  
  def dom_id_with_associations(record, *args) 
    opts = args.extract_options!
    prefix = args.shift
    sub_dom_id = nil
    subarr = opts[:include].is_a?(Array) ? opts[:include] : [opts[:include]]
    if !opts[:include].blank?
      next_sym = subarr.pop
      if next_sym.respond_to?(:display_name)
        sub_dom_id = dom_id(next_sym, :include => subarr)
      else
        sub_dom_id = dom_id(record.send(next_sym), :include => subarr)
      end
    end
    [ prefix, sub_dom_id, singular_class_name(record), (record.scoped_id rescue record.id) ].compact * '-'
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