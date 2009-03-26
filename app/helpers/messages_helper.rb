module MessagesHelper
  # Borrows heavily from articles_helper.rb and comments_helper.rb
  def format_message(message, opts={})
    opts[:message] ||= message
    text = escape_code_html(message.body.blank? ? '' : message.body)
    formatted = Hpricot(p_wrap(text))
    clean_code_breaks(formatted)
    clarify_external_links(formatted)
    text = sanitize(formatted.to_html, :tags => allowed_tags(opts[:truncate]), :attributes => allowed_attributes)
    hpricot = Hpricot(text)
    hpricot.each_child do |child|
      child.set_attribute('class', opts[:class] || 'messageContent') if child.elem?
    end
    opts[:truncate] ? truncate_html(hpricot.to_s, opts[:truncate]) : hpricot.to_s
  end
end
