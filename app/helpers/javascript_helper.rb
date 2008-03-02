module JavascriptHelper
  def add_inline_scripts(content, kind=nil)
    if @config[:scripts_at_bottom]
      case kind
      when :add_behavior
        content
        (@extra_behaviors ||= []) << content
      else
        content += ';' unless content.rstrig.last == ';'
        (@extra_scripts ||= []) << content
      end
      return nil
    else
      javascript_tag(kind == :add_behavior ? "Event.addBehavior({#{content}});" : content)
    end
  end
  
  def add_scripts(kind=nil, &block)
    if @config[:scripts_at_bottom]
      res = (str = capture(&block).rstrip).last == ';' ? str : "#{str};"
      case kind
      when :add_behavior
        (@extra_behaviors ||= []) << res; return nil
      when nil
        (@extra_scripts ||= []) << res; return nil
      else
        raise ArgumentError, "Invalid `kind` in arguments. Expected nil or predefined symbols."
      end
    else
      concat('<script type="text/javascript">', block.binding)
      concat(capture(&block), block.binding)
      concat('</script>', block.binding)
    end
  end
  
  def add_behavior(selector, behavior)
    add_inline_scripts("'#{selector}' : #{behavior}", :add_behavior)
  end
end