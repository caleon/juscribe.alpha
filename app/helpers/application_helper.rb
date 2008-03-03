# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def body_tag_for(record, *args, &block)
    options = args.extract_options!
    concat content_tag(:body, capture(&block),
                       options.merge({ :id => "#{record.class.class_name}_page" })),
                       block.binding
  end
  
  def main_record
    @user || @group || @widget || @article || @event || @entry || @list || @item
  end
end
