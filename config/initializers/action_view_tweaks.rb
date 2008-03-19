module ActionView::Helpers
  module ActiveRecordHelper
    def error_messages_for_with_format(*params)
      options = params.extract_options!.symbolize_keys
      if object = options.delete(:object)
        objects = [objects].flatten
      else
        objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
      end
      count = objects.inject(0) {|sum, object| sum + object.errors.count }
      return '' if count.zero?
      html = {}    
      html[:id] = options[:id] || 'errorExplanation'
      html[:class] = options[:class] || 'errorExplanation'

      options[:object_name] ||= params.first
      options[:header_message] ||= "#{pluralize(count, 'error')} prohibited this #{options[:object_name].to_s.gsub('_', ' ')} from being saved"
      options[:message] ||= 'There were problems with the following fields:'
      error_messages = objects.map {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) } }

      contents = ''
      contents << content_tag(options[:header_tag] || :h2, options[:header_message]) unless options[:header_message].blank?
      contents << content_tag(:p, options[:message]) unless options[:message].blank?
      contents << content_tag(:ul, error_messages.slice!(0..(count/2) + (count %2)))
      contents << content_tag(:ul, error_messages)

      content_tag(:div, contents, html)
    end
    alias_method_chain :error_messages_for, :format
  end
  
  module TextHelper
    def simple_format_with_options(text, opts={})
      open_p = %{<p#{opts[:class] ? " class=\"#{opts[:class]}\"" : ''}>}
      content_tag 'p', text.to_s.
        gsub(/\r\n?/, "\n").                    # \r\n and \r -> \n
        gsub(/\n\n+/, "</p>\n\n#{open_p}").           # 2+ newline  -> paragraph
        gsub(/([^\n]\n)(?=[^\n])/, '\1<br />'), # 1 newline   -> br
        opts
    end
    alias_method_chain :simple_format, :options
  end
  
  module JavaScriptHelper
    def javascript_tag_with_flip_flop(content, html_options={})
      if @config[:scripts_at_bottom]
        add_inline_scripts(content, html_options)
      else
        orig_javascript_tag(content, html_options)
      end
    end
    alias_method_chain :javascript_tag, :flip_flop
  end
end
