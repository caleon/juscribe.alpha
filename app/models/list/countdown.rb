class Countdown < List
  alias :old_items :items
  def items; self.old_items.reversed end
end
