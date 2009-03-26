module FormHelper
  def dom_name_for(record)
    record.class.table_name.singularize
  end
    
  def info_box_for(record, field, info='')
    content_tag(:span, info, :class => "info",
                             :id => "#{dom_name_for(record)}_#{field}-info", :style => 'display: none;') +
    (record.respond_to?(field) ? content_tag(:span, error_message_on(record, field), :class => "error", :id => "#{dom_name_for(record)}_#{field}-error") : '')
  end
end