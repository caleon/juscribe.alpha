module ActionView
  module Helpers
    module JavaScriptHelper
      alias_method :orig_javascript_tag, :javascript_tag
      def javascript_tag(content, html_options={})
        if @config[:scripts_at_bottom]
          # TODO: it should be possible to include html_options into args, no?
          add_inline_scripts(content)
        else
          orig_javascript_tag(content, html_options)
        end
      end
    end
  end
end
