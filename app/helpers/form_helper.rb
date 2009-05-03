module FormHelper
  def dom_name_for(record)
    record.class.table_name.singularize
  end
    
  def info_box_for(record, field, info='')
    #content_tag(:span, info, :class => "info",
    #                         :id => "#{dom_name_for(record)}_#{field}-info", :style => 'display: none;') +
    info_box(:record => record, :field => field, :info => info) + 
    (record.respond_to?(field) ? content_tag(:span, error_message_on(record, field), :class => "error", :id => "#{dom_name_for(record)}_#{field}-error") : '')
  end
  
  def info_box(*args)
    opts = args.extract_options!
    if opts[:record] && opts[:field]
      dom_prefix = "#{dom_name_for(opts[:record])}_#{opts[:field]}"
    else
      dom_prefix = args.shift || 'generic'
    end
    content_tag(:span, opts[:info], :class => 'info', :id => "#{dom_prefix}-info", :style => 'display: none;')
  end
end