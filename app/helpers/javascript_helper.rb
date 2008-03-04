module JavascriptHelper
  
  def add_behavior(selector, behavior)
    add_inline_scripts("'#{selector}' : #{behavior}", :add_behavior)
  end
  
  def add_inline_scripts(content, kind=nil)
    if @config[:scripts_at_bottom]
      add_by_type(kind, content, true)
    else
      javascript_tag(kind == :add_behavior ? "Event.addBehavior({#{content}});" : content)
    end
  end
  
  def add_scripts(kind=nil, &block)
    if @config[:scripts_at_bottom]
      add_by_type(kind, res)
    else
      concat('<script type="text/javascript">', block.binding)
      concat(capture(&block), block.binding)
      concat('</script>', block.binding)
    end
  end
  
  def extra_behaviors
    "Event.addBehavior({" + @extra_behaviors.join(', ') + "});" unless @extra_behaviors.blank?
  end
  
  def print_scripts_block?(pos)
    if pos == :top
      !@content_for_extra_top_scripts.blank?
    else
      !(@extra_behaviors.blank? && @content_for_extra_bottom_scripts.blank?)
    end
  end
  
  #######
  private
  #######
  def add_by_type(kind=nil, content, inline=false)
    case kind
    when :add_behavior
      add_to_behaviors(res)
    when nil
      add_to_scripts(res)
    else
      raise ArgumentError, "Invalid `kind` in arguments. Expected nil or predefined symbols."
    end
  end
  
  def add_to_behaviors(content)
    add_to_js_array(:behaviors, content)
  end
  
  def add_to_scripts(content)
    add_to_js_array(:scripts, content)
  end
  
  def add_to_js_array(kind, content)
    content.strip!
    content += ';' unless content.rstrip.last == ';'
    case kind
    when :behaviors
      (@extra_behaviors ||= []) << content
    when :scripts
      (@extra_scripts ||= []) << content
    else
    end
  end
end