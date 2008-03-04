module ActionView
  module Helpers
    module JavaScriptHelper
      alias_method :orig_javascript_tag, :javascript_tag
      def javascript_tag(content, html_options={})
        if @config[:scripts_at_bottom]
          add_inline_scripts(content, html_options)
        else
          orig_javascript_tag(content, html_options)
        end
      end
    end
  end
end
