# By Henrik Nyh <http://henrik.nyh.se> 2008-01-30.
# Free to modify and redistribute with credit.

# modified by Dave Nolan http://textgoeshere.org.uk 
# Ellipsis appended to text of last HTML node
# Ellipsis inserted after final word break
module TextHelper

  # Like the Rails _truncate_ helper but doesn't break HTML tags or entities.
  def truncate_html(text, max_length = 30, ellipsis = "...")
    return if text.nil?

    doc = Hpricot(text.to_s)
    ellipsis_length = Hpricot(ellipsis).inner_text.mb_chars.length
    content_length = doc.inner_text.mb_chars.length
    actual_length = max_length - ellipsis_length

    if content_length > max_length
      truncated_doc = doc.truncate(actual_length)
      last_child = truncated_doc.children.last
      last_child.inner_html = last_child.inner_html.gsub(/\W.[^\s]+$/, "") + ellipsis if last_child.inner_html
      truncated_doc.to_s + (last_child.inner_html ? '' : ellipsis)
    else
      text.to_s
    end
  end

end

module HpricotTruncator
  module NodeWithChildren
    def truncate(max_length)
      return self if inner_text.mb_chars.length <= max_length
      truncated_node = self.dup
      truncated_node.children = []
      each_child do |node|
        remaining_length = max_length - truncated_node.inner_text.mb_chars.length
        break if remaining_length == 0
        truncated_node.children << node.truncate(remaining_length)
      end
      truncated_node
    end
  end

  module TextNode
    def truncate(max_length)
      # We're using String#scan because Hpricot doesn't distinguish entities.
      Hpricot::Text.new(content.scan(/&#?[^\W_]+;|./).first(max_length).join)
    end
  end

  module IgnoredTag
    def truncate(max_length)
      self
    end
  end
end

Hpricot::Doc.send(:include,       HpricotTruncator::NodeWithChildren)
Hpricot::Elem.send(:include,      HpricotTruncator::NodeWithChildren)
Hpricot::Text.send(:include,      HpricotTruncator::TextNode)
Hpricot::BogusETag.send(:include, HpricotTruncator::IgnoredTag)
Hpricot::Comment.send(:include,   HpricotTruncator::IgnoredTag)
