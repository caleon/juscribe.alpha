# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def body_tag_for(*args, &block)
    opts = args.extract_options!
    record = args.shift
    concat content_tag(:body, capture(&block),
                       (opts.merge(record ? { :id => "#{record.class}_page" } : {}))),
           block.binding
  end
  
  def main_record
    @user || @group || @widget || @article || @event || @entry || @list || @item
  end
end
