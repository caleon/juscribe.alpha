module JavascriptHelper
  def add_script_file(arg)
    (@script_files ||= []) << arg
  end
  
  def link_script_files
    (@script_files ||= []).map do |script|
      javascript_include_tag script.to_s
    end.join('\r\n')
  end
  
  def add_onload(arg)
    (@onloads ||= []) << arg
  end
  
  def add_behavior(selector, behavior)
    add_inline_scripts("'#{selector}' : #{behavior}", :add_behavior)
  end
  
  def add_inline_scripts(content, *args)
    html_opts = args.extract_options!
    kind = args.shift
    if SITE[:scripts_at_bottom]
      add_by_type(content, kind, true)
    else
      javascript_tag((kind == :add_behavior ? "Event.addBehavior({#{content}});" : content), html_opts)
    end
  end
  
  def add_scripts(kind=nil, &block)
    if SITE[:scripts_at_bottom]
      res = capture(&block)
      add_by_type(res, kind)
    else
      concat('<script type="text/javascript">', block.binding)
      concat(capture(&block), block.binding)
      concat('</script>', block.binding)
    end
  end
  
  def add_extra_top_scripts(&block)
    add_extra_top_or_bottom_scripts(:top, &block)
  end
  
  def add_extra_bottom_scripts(&block)
    add_extra_top_or_bottom_scripts(:bottom, &block)
  end
  
  def extra_scripts(pos=nil)
    case pos
    when :top
      @extra_top_scripts.join("\r\n") if @extra_top_scripts.is_a?(Array)
    when :bottom
      @extra_bottom_scripts.join("\r\n") if @extra_bottom_scripts.is_a?(Array)
    else
      @extra_scripts.join("\r\n") if @extra_scripts.is_a?(Array)
    end
  end
  
  def extra_behaviors
    "Event.addBehavior({" + @extra_behaviors.join(', ') + "});" unless @extra_behaviors.blank?
  end
  
  def print_scripts_block?(pos=nil)
    if pos == :top
      !(@extra_behaviors.blank? && @extra_top_scripts.blank?)
    elsif pos == :bottom
      !(@extra_behaviors.blank? && @extra_bottom_scripts.blank?)
    else
      !@extra_scripts.blank?
    end
  end
  

  def add_by_type(content, kind=nil, inline=false)
    case kind
    when :add_behavior
      add_to_behaviors(content)
    when nil
      add_to_scripts(content)
    else
      raise ArgumentError, "Invalid `kind` in arguments. Expected nil or predefined symbols."
    end
  end
  
  def add_extra_top_or_bottom_scripts(pos, &block)
    res = capture(&block)
    if pos == :top
      (@extra_top_scripts ||= []) << res
    else
      (@extra_bottom_scripts ||= []) << res
    end
  end
  
  def add_to_behaviors(content)
    add_to_js_array(:behaviors, content, :no_semicolon => true)
  end
  
  def add_to_scripts(content)
    add_to_js_array(:scripts, content)
  end
  
  def add_to_js_array(kind, content, opts={})
    content.strip!
    content += ';' if content.rstrip.last != ';' && !opts[:no_semicolon]
    case kind
    when :behaviors
      (@extra_behaviors ||= []) << content
    when :scripts
      (@extra_scripts ||= []) << content
    else
    end
    return nil
  end
end