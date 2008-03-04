# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  ### Refer to config/initializers/action_controller_tweaks.rb
  def responding_types
    @responding_types ||= [:html]
  end
  
  def action_accepts?(type)
    responding_types.include?(type)
  end
  
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
  
  def notice_field
    content_tag(:div, flash[:notice], :id => 'flashNotice', :class => 'flashNotice') if flash[:notice]
  end
  
end
